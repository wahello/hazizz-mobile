// EZT NÉZD MEG -->https://github.com/Solido/awesome-flutter
import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/managers/app_state_manager.dart';
import 'package:mobile/managers/token_manager.dart';
import 'package:mobile/communication/hazizz_response.dart';
import 'connection.dart';
import 'custom_response_errors.dart';
import 'htttp_methods.dart';

Future<HazizzResponse> getResponse(Request request, {bool useSecondaryOptions = false})async{
  return await RequestSender().getResponse(request, useSecondaryOptions: useSecondaryOptions);
}

class RequestSender{

  List<Request> refreshRequestQueue = List();

  static final RequestSender _instance = new RequestSender._internal();
  
  bool _isLocked = false;

  factory RequestSender() {
    return _instance;
  }

  int lastSeconds = DateTime.now().millisecondsSinceEpoch;

  int requestCount = 0;

  RequestSender._internal(){
    addInterceptor();
  }

  addInterceptor(){
    defaultDio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) async{
          HazizzLogger.printLog("In onRequest function");
          if(DateTime.now().millisecondsSinceEpoch - lastSeconds >= 1000){
            print("boi: b2");
            lastSeconds = DateTime.now().millisecondsSinceEpoch;
            requestCount = 1;
          }else{
            print("boi: b3");
            if(requestCount >= 3){
              print("boi: b4");
              print("oops: too many requests. Waiting");
              await Future.delayed(const Duration(milliseconds: 1000));
            }
            print("boi: b5");
            requestCount++;
          }
          HazizzLogger.printLog("In onRequest function: sending request: ${options.baseUrl}");

          return options;
        },
        onResponse:(Response response) {
          HazizzLogger.printLog("got response: ${response.data}");

          return response; // continue
        },
        onError: (DioError e) async{
          HazizzLogger.printLog("got response error: ${e}");
          return  e;//continue
        }
    ));
  }

  static final BaseOptions defaultOptions = new BaseOptions(
      connectTimeout: 10000,
      sendTimeout: 10000,
      receiveTimeout: 10000,
      responseType: ResponseType.plain,
      receiveDataWhenStatusError: true,
      followRedirects: true,

  );
  final Dio defaultDio = new Dio(defaultOptions);


  static final BaseOptions secondaryOptions = new BaseOptions(
      connectTimeout: 20000,
      sendTimeout: 20000,
      receiveTimeout: 20000,
      responseType: ResponseType.plain,
      receiveDataWhenStatusError: true,
      followRedirects: true
  );
  final Dio secondaryDio = new Dio(secondaryOptions);


  static final BaseOptions theraOptions = new BaseOptions(
      connectTimeout: 16000,
      sendTimeout: 16000,
      receiveTimeout: 16000,
      responseType: ResponseType.plain,
      receiveDataWhenStatusError: true,
      followRedirects: true
  );
  final Dio theraDio = new Dio(theraOptions);



  void initialize(){
    defaultDio.transformer = new FlutterTransformer();
    addInterceptor();
    HazizzLogger.hprint("dio options: ${defaultOptions.toString()}");
  }

  Future<void> waitCooldown() async{
    lock();
    await new Future.delayed(const Duration(milliseconds: 1000));
    unlock();
  }
  void lock(){
 //   refreshRequestQueue.clear();
    defaultDio.lock();
    _isLocked = true;
    HazizzLogger.printLog("dio interceptors: locked");
  }

  Future unlock() async {
    defaultDio.unlock();
    _isLocked = false;
    HazizzLogger.printLog("dio interceptors: unlocked");
  }
  Future unlockTokenRefreshRequests() async {
    await clearQueue();
    for(Request r in refreshRequestQueue){
      r = await refreshTokenInRequest(r);
      getResponse(r);
    }
    refreshRequestQueue.clear();

    defaultDio.unlock();
    _isLocked = false;
    HazizzLogger.printLog("(unlockTokenRefreshRequests) dio interceptors: unlocked");
  }

  bool isLocked(){
    return _isLocked;
  }
  Future<HazizzResponse> getAuthResponse(AuthRequest authRequest) async{
    HazizzLogger.printLog("about to start sending AUTH request: ${authRequest.toString()}");
    HazizzResponse hazizzResponse;
    try{
      final Dio authDio = Dio(defaultOptions);
      Response response = await authDio.post(authRequest.url, queryParameters: authRequest.query, data: authRequest.body, options: Options(headers: await authRequest.buildHeader()));
      hazizzResponse = HazizzResponse.onSuccess(response: response, request: authRequest);

      HazizzLogger.printLog("hey: sent token request");
    }on DioError catch(error){
      if(error.response != null) {
        HazizzLogger.printLog("log: error response data: ${error.response.data}");
      }
      hazizzResponse = await HazizzResponse.onError(dioError: error, request: authRequest);
      if(hazizzResponse.pojoError != null){
        if(hazizzResponse.pojoError.errorCode == 21){
          await AppState.logout();
        }
      }

      HazizzLogger.printLog("auth response is successful: ${hazizzResponse.isSuccessful}");
    }
    return hazizzResponse;
  }

  Set<Request> noConnectionRequestsPrioritized = Set();
  List<Request> noConnectionRequests = List();

  void addToPendingList(Request newRequest){

    if(newRequest is CreateToken){
      noConnectionRequestsPrioritized.add(newRequest);
    }

    if(noConnectionRequests.isNotEmpty){
      for(int i = 0; i < noConnectionRequests.length; i++){
        if(noConnectionRequests[i] == newRequest){
          noConnectionRequests[i] = newRequest;
        }
      }
    }else{
      noConnectionRequests.add(newRequest);
    }
  }

  Future sendPendingRequests() async {
    for(Request request in noConnectionRequestsPrioritized){
      await RequestSender().getResponse(request);
    }
    for(Request request in noConnectionRequests){
      await RequestSender().getResponse(request);
    }
  }

  Future clearPending() async {

    noConnectionRequestsPrioritized.clear();
    noConnectionRequests.clear();
  }

  Future clearQueue() async {
    await defaultDio.clear();
  }

  clearAllRequests() async {
    await clearPending();
    await clearQueue();
  }

  Future<HazizzResponse> getResponse(Request request, {bool useSecondaryOptions = false}) async{

    final DateTime lastUpdate = await TokenManager.getLastTokenUpdateTime();
    if(lastUpdate == null || lastUpdate.difference(DateTime.now()).inHours >= 24){
      await TokenManager.createTokenWithRefresh();
    }

    HazizzResponse hazizzResponse;

    Response response;

    HazizzLogger.printLog("about to start sending request: ${request.toString()}");

    if(isLocked()) HazizzLogger.printLog("Dio interceptor is locked: ${request.toString()}");

    bool isConnected = await Connection.isOnline();
    print("isConnexcted: $isConnected");
    try {
      if(isConnected) {
        HazizzLogger.printLog("request query: ${request.query}");
        HazizzLogger.printLog("request url: ${request.url}");

        Dio currentDio;
      //  BaseOptions currentOption;

        if(useSecondaryOptions){
          currentDio = secondaryDio;
        }else if(request is TheraRequest){
          currentDio = theraDio;
        }else{
          currentDio = defaultDio;
        }
        print("öiaö: 0");

        final Options option = Options(headers: await request.buildHeader());
        print("öiaö: 1");

        if(request.httpMethod == HttpMethod.GET) {
          print("öiaö: 2");
          response = await currentDio.get(request.url, queryParameters: request.query, options: option);
        }else if(request.httpMethod == HttpMethod.POST) {
          print("öiaö: 3");
          response = await currentDio.post(request.url, queryParameters: request.query, data: request.body, options: option);
        }else if(request.httpMethod == HttpMethod.DELETE) {
          response = await currentDio.delete(request.url, queryParameters: request.query, data: request.body, options: option);
        }else if(request.httpMethod == HttpMethod.PATCH) {
          response = await currentDio.patch(request.url, queryParameters: request.query, data: request.body, options: option);
        }else if(request.httpMethod == HttpMethod.PUT) {
          response = await currentDio.put(request.url, queryParameters: request.query, data: request.body, options: option);
        }

        HazizzLogger.printLog("request was sent successfully: ${request.toString()}");
        HazizzLogger.printLog("response for ${request.toString()}: ${response.toString()}");
        hazizzResponse = HazizzResponse.onSuccess(response: response, request: request);
        HazizzLogger.printLog("HazizzResponse.onSuccess ran: ${request.toString()}");

      }else{
        HazizzLogger.printLog("No network connection, can't send request: ${request.toString()}");
        throw noConnectionError;
      }
    }on DioError catch(error) {
      HazizzLogger.printLog("response is error: ${request.toString()}");

      hazizzResponse = await HazizzResponse.onError(dioError: error, request: request);
      HazizzLogger.printLog("HazizzResponse.onError ran: ${request.toString()}");
    }
    return hazizzResponse;
  }
}