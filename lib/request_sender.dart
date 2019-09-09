// EZT NÉZD MEG -->https://github.com/Solido/awesome-flutter
import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
//import 'package:mobile/packages/hazizz-dio-2.1.3/lib/dio.dart';
import 'HttpMethod.dart';

import 'communication/connection.dart';
import 'communication/errors.dart';
import 'communication/requests/request_collection.dart';
import 'hazizz_response.dart';
import 'logger.dart';
import 'managers/app_state_manager.dart';

Future<HazizzResponse> getResponse(Request request)async{
  return await RequestSender().getResponse(request);
}

class RequestSender{
  static final RequestSender _instance = new RequestSender._internal();
  
  bool _isLocked = false;

  factory RequestSender() {
    return _instance;
  }

  RequestSender._internal(){

    dio.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options) async{
        // Do something before request is sent
        /*
        dio.interceptors.requestLock.lock();
        dio.clear();
        */
        /*
        connectivity = await Connectivity().checkConnectivity();
        if(!(connectivity == ConnectivityResult.wifi ||connectivity == ConnectivityResult.mobile)){
          dio.lock();
        }
        */
        print("log: sent request");
        return options; //continue
        // If you want to resolve the request with some custom data，
        // you can return a `Response` object or return `dio.resolve(data)`.
        // If you want to reject the request with a error message,
        // you can return a `DioError` object or return `dio.reject(errMsg)`
      },
      onResponse:(Response response) {
        // Do something with response data
        print("log: got response: ${response.data}");

        return response; // continue
      },
      onError: (DioError e) async{
        print("log: got error: ${e}");

        // Do something with response error
       // return  e;//continue
      }
    ));
  }
  /*
      String method,
      int connectTimeout,
      int sendTimeout,
      int receiveTimeout,
      Iterable<Cookie> cookies,
      Map<String, dynamic> extra,
      Map<String, dynamic> headers,
      ResponseType responseType,
      ContentType contentType,
      ValidateStatus validateStatus,
      bool receiveDataWhenStatusError,
      bool followRedirects,
      int maxRedirects,
  */
  final Options options = new Options(
    /*
    responseDecoder: (List<int> responseBytes, RequestOptions options, ResponseBody responseBody){
      responseBody.
    },
    */

    connectTimeout: 6000,
    sendTimeout: 6000,
    receiveTimeout: 6000,
  //  headers: request.header,
    responseType: ResponseType.plain,
    receiveDataWhenStatusError: true,
    followRedirects: true,


  );

  Dio dio = new Dio();

  void initalize(){
    dio = new Dio();
    dio.transformer = new FlutterTransformer();
  }

  Future<void> waitCooldown() async{
    dio.interceptors.requestLock.lock();
    await new Future.delayed(const Duration(milliseconds: 1000));
    dio.interceptors.requestLock.unlock();
  }
  void lock(){
    dio.lock();
    _isLocked = true;
    logger.w("request_sender.dart: dio interceptors: locked");

  }
  void unlock(){
    dio.unlock();
    _isLocked = false;
    logger.w("request_sender.dart: dio interceptors: UNlocked");

  }
  bool isLocked(){
    return _isLocked;
  }
  Future<HazizzResponse> getTokenResponse(AuthRequest authRequest) async{
    HazizzResponse hazizzResponse;
    try{
      options.headers = await authRequest.buildHeader();
      Dio authDio = Dio();
      Response response = await authDio.post(authRequest.url, queryParameters: authRequest.query, data: authRequest.body, options: options);
      hazizzResponse = HazizzResponse.onSuccess(response: response, request: authRequest);

      print("hey: sent token request");
    }on DioError catch(error){
      if(error.response != null) {
        print("log: error response data: ${error.response.data}");
      }
      hazizzResponse = await HazizzResponse.onError(dioError: error, request: authRequest);
      if(hazizzResponse.hasPojoError && hazizzResponse.pojoError.errorCode == 21){
        AppState.logout();
      }


      print(hazizzResponse);
    }
    return hazizzResponse;
  }

  /*
  Future<void> onPojoError2(PojoError pojoError, Request request) async{
    if (true) {
      // print("log: error response data: ${error.response.data}");
      // PojoError pojoError = PojoError.fromJson(json.decode(error.response?.data));

      if(pojoError.errorCode == 19){// to many requests
        print("here iam");
        stop();
      }
      else if(pojoError.errorCode == 18 || pojoError.errorCode == 17){// wrong token
        // a requestet elmenteni hogy újra küldje
        print("hey: Locked: ${isLocked()}");
        if(!isLocked()) {
          lock();
          // elküldi újra ezt a requestet ami errort dobott
          send(request);
          print("hey2: username: ${await InfoCache.getMyUsername()}");
          print("hey2: token: ${await TokenManager.getRefreshToken()}");

          await tokenRequestSend(new CreateTokenWithRefresh(
              b_username: await InfoCache.getMyUsername(),
              b_refreshToken: await TokenManager.getRefreshToken(),
              rh: ResponseHandler(
                  onSuccessful: (dynamic data) {
                    print("hey: got token reponse: ${data.token}");
                    unlock();
                  },
                  onError: (PojoError pojoError) {
                    unlock();

                  }
              )
          ));
        }else{
          send(request);
        }
        //  request.rh.onSuccessful();
      }else if(pojoError.errorCode == 13 || pojoError.errorCode == 14
          || pojoError.errorCode == 15){
        // navigate to login/register page
      }
      https://github.com/hazizz/hazizz-mobile
      print("log: response error: ${pojoError.toString()}");
      //  throw new HResponseError(pojoError);
      return pojoError;
      //  return pojoError;
      request.onError(pojoError);
    }

    //  return error.response;
  }
  */


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
    await dio.clear();
  }

  clearAllRequests() async {
    await clearPending();
    await clearQueue();
  }



  Future<HazizzResponse> getResponse(Request request) async{

    HazizzResponse hazizzResponse;

    Response response;

    logger.i("request_sender.dart: about to start sending request: ${request.toString()}");

    if(isLocked()) logger.i("DIO INTERCEPTOR LOCKED");

    bool isConnected = await Connection.isOnline();
    print("GOT 'ERE: 1");
    try {
      if(isConnected) {
        print("GOT 'ERE: ${request.query}");

        if(request.httpMethod == HttpMethod.GET) {
          options.headers = await request.buildHeader();
          response = await dio.get(request.url, queryParameters: request.query, options: options);

        }else if(request.httpMethod == HttpMethod.POST) {
          options.headers = await request.buildHeader();
          response = await dio.post(request.url, queryParameters: request.query, data: request.body, options: options);
        }else if(request.httpMethod == HttpMethod.DELETE) {
          options.headers = await request.buildHeader();
          response = await dio.delete(request.url, queryParameters: request.query, data: request.body, options: options);
        }else if(request.httpMethod == HttpMethod.PATCH) {
          options.headers = await request.buildHeader();
          response = await dio.patch(request.url, queryParameters: request.query, data: request.body, options: options);
        }

        print("GOT 'ERE: 3");
        hazizzResponse = HazizzResponse.onSuccess(response: response, request: request);
       // print("log: request sent: ${request.toString()}");
        logger.i("request_sender.dart: request sent: ${request.toString()}");

      }else{
        logger.w("request_sender.dart: no connection");
        throw noConnectionError;
      }
    }on DioError catch(error) {
      logger.i("request_sender.dart: request error: ${request.toString()}");

      hazizzResponse = await HazizzResponse.onError(dioError: error, request: request);
    }
    return hazizzResponse;
  }
}