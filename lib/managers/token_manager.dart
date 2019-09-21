
import 'package:intl/intl.dart';
import 'package:mobile/communication/errorcode_collection.dart';
import 'package:mobile/communication/pojos/PojoError.dart';
import 'package:mobile/communication/pojos/PojoTokens.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:meta/meta.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/navigation/business_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../request_sender.dart';
import '../hazizz_response.dart';
import 'app_state_manager.dart';
import 'cache_manager.dart';

class LoginError implements Exception{

}

class WrongUsernameException implements LoginError{
  @override
  String toString() => "WrongUsernameException";
}

class WrongPasswordException implements LoginError{
  @override
  String toString() => "WrongUsernameException";
}


SharedPreferences sp;

Future<SharedPreferences> getSp()async {
  if(sp == null){
    sp = await SharedPreferences.getInstance();
  }
}


class KretaAccount{
  String kretaSession;

  static const String _keyKretaUsername = "key_KretaUsername_";


  KretaAccount({@required this.kretaSession}){

  }




}
/*
class HazizzAccount{
  static const String _keyToken = "key_token_";
  static const String _keyRefreshToken = "key_refreshToken_";
  static const String _keyUsername = "key_username_";
  static const String _keyDisplayname = "key_displayname_";

  static const String _keyKretaSessions = "key_kretaSessions_";

  static const String _keyCurrentKretaSession = "key_currentKretaSession";


  static const String _keyKretaSessionsAmount = "key_kretaSessionsAmount_";


  List<String> kretaSessions = [];

  int kretaSessionAmount;

  String currentKretaSession;
  KretaAccount currentKretaAccount;

  Future<int> getKretaSessionAmount() async {
    String str_kretaAccountAmount = sp.getString(_keyKretaSessionsAmount + userId.toString());
    kretaSessionAmount = int.parse(str_kretaAccountAmount);
    return kretaSessionAmount;
  }

  Future<void> addKretaSessionAmount() async {
    String str_kretaAccountAmount = sp.getString(_keyKretaSessionsAmount + userId.toString());
    kretaSessionAmount = int.parse(str_kretaAccountAmount);
    kretaSessionAmount++;
    await sp.setString(_keyKretaSessionsAmount + userId.toString(), kretaSessionAmount.toString());
  }

  Future<void> subtractKretaSessionAmount() async {
    String str_kretaAccountAmount = sp.getString(_keyKretaSessionsAmount + userId.toString());
    kretaSessionAmount = int.parse(str_kretaAccountAmount);
    kretaSessionAmount--;
    await sp.setString(_keyKretaSessionsAmount + userId.toString(), kretaSessionAmount.toString());
  }




  void getKretaSessions() async{
    List<String> sessions = [];
    getKretaSessionAmount();
    for(int i = 0; i < kretaSessionAmount; i++){
      sessions.add(sp.getString(_keyKretaSessions + userId.toString() + "_" + i.toString()));
    }
    kretaSessions = sessions;
  }

  Future saveKretaSession(String session) async {
    getKretaSessionAmount();
    sp.setString(_keyKretaSessions + userId.toString() + "_" + kretaSessionAmount.toString(), session);
    await addKretaSessionAmount();
  }

  getCurrentKretaSession() async {
    currentKretaSession = sp.getString(_keyCurrentKretaSession);
  }
  Future setCurrentKretaSession(String session) async {
    await sp.setString(_keyCurrentKretaSession, session);
  }

  getCurrentKretaAccount(){
    if(currentKretaAccount == null) {
      getCurrentKretaSession();
      if(currentKretaSession != null) {
        currentKretaAccount = KretaAccount(kretaSession: currentKretaSession);
        return currentKretaAccount;
      }
      return null;
    }
    return currentKretaAccount;
  }





  int userId;
  HazizzAccount({@required this.userId}){
    getSp();
  }

  static bool tokenIsValid = true;



   Future<String> getMyUsername() async{
    return sp.getString(_keyUsername + userId.toString());
  }

   void forgetMyUsername() async{
     sp.setString(_keyUsername + userId.toString(), null);
  }

   void setMyUsername(String myUsername) async{
     sp.setString(_keyUsername + userId.toString(), myUsername);
  }

   Future<String> getMyDisplayName() async{
    return sp.getString(_keyDisplayname + userId.toString());
  }

   void setMyDisplayName(String myDisplayName) async{
     sp.setString(_keyDisplayname + userId.toString(), myDisplayName);
  }




  Future<bool> hasToken() async{
   // final SharedPreferences sp = await SharedPreferences.getInstance();
    String token = sp.getString("$_keyToken$userId");
    return !(token == null || token == "");
  }

  Future<String> get token async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("$_keyToken$userId");
  }

   Future<String> getToken() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("$_keyToken$userId");
  }











   Future<void> fetchTokens(@required String username, @required String password) async{
    HazizzResponse hazizzResponse = await RequestSender().getResponse(new CreateToken.withPassword(q_username: username, q_password: password));
    if(hazizzResponse.isSuccessful){
      HazizzLogger.printLog("log: token: tokens set");

      PojoTokens tokens = hazizzResponse.convertedData;

      InfoCache.setMyUsername(username);
      setToken(tokens.token);
      setRefreshToken(tokens.refresh);
      setTokenRefreshTime();
    }else if(hazizzResponse.isError){

      int errorCode = hazizzResponse.pojoError.errorCode;
      HazizzLogger.printLog("log: errorCode: $errorCode");
      if(ErrorCodes.INVALID_PASSWORD.equals(errorCode)){
        throw new WrongPasswordException();
      }else if(ErrorCodes.USER_NOT_FOUND.equals(errorCode)){
        throw new WrongUsernameException();
      }
    }
    HazizzLogger.printLog("log: fetch token: done");
  }

   Future<void> fetchRefreshTokens({@required String username, @required String refreshToken}) async{
    HazizzResponse hazizzResponse = await RequestSender().getAuthResponse(new CreateToken.withRefresh(q_username: username, q_refreshToken: refreshToken));
    if(hazizzResponse.isSuccessful){
      PojoTokens tokens = hazizzResponse.convertedData;
      InfoCache.setMyUsername(username);
      setToken(tokens.token);
      setRefreshToken(tokens.refresh);
      setTokenRefreshTime();
    }else if(hazizzResponse.hasPojoError){
      int errorCode = hazizzResponse.pojoError.errorCode;
      if(ErrorCodes.INVALID_PASSWORD.equals(errorCode)){
        throw WrongPasswordException;
      }else if(ErrorCodes.USER_NOT_FOUND.equals(errorCode)){
        throw WrongUsernameException();
      }
    }
  }

  Future<String> get refreshToken2 async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("$_keyRefreshToken$userId");
  }

   Future<String> getRefreshToken() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("$_keyRefreshToken$userId");
  }

   void setToken(String newToken) async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("$_keyToken$userId", newToken);
  }

   void setRefreshToken(String newRefreshToken) async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("$_keyRefreshToken$userId", newRefreshToken);
  }

   Future<bool> hasRefreshToken() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String refreshToken = sp.getString("$_keyRefreshToken$userId");
    return !(refreshToken == null || refreshToken == "");
  }

  static const String _keyLastTokenRefreshTime = "key_LastTokenRefreshTime";
  static const String _timeFormat = "dd/MM/yyyy HH:mm:ss";

   Future checkAndFetchTokenRefreshIfNeeded() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String str_lastTokenRefreshTime = sp.getString("$_keyLastTokenRefreshTime$userId");
    if(str_lastTokenRefreshTime != null){
      DateTime lastTokenRefreshTime = DateFormat(_timeFormat).parse(_keyLastTokenRefreshTime);//DateTime.parse(str_lastTokenRefreshTime);
      if(lastTokenRefreshTime != null &&
          DateTime.now().difference(lastTokenRefreshTime).inSeconds.abs() >= 24*60*60)
      {
       // RequestSender().lock();
        fetchRefreshTokens(username: await InfoCache.getMyUsername(), refreshToken: await getRefreshToken());
       // RequestSender().unlock();
      }
    }
  }

   Future<bool> checkIfTokenRefreshIsNeeded() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String str_lastTokenRefreshTime = sp.getString("$_keyLastTokenRefreshTime$userId");
    if(str_lastTokenRefreshTime != null && str_lastTokenRefreshTime != ""){
      DateTime lastTokenRefreshTime = DateFormat(_timeFormat).parse(str_lastTokenRefreshTime);//DateTime.parse(str_lastTokenRefreshTime);
      if(lastTokenRefreshTime != null &&
          DateTime.now().difference(lastTokenRefreshTime).inSeconds.abs() >= 24*60*60)
      {
        return true;
      }
    }
    return false;
  }

   Future fetchToken() async {
    await fetchRefreshTokens(username: await InfoCache.getMyUsername(), refreshToken: await getRefreshToken());
  }

   Future setTokenRefreshTime() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String lastTokenRefreshTime = DateFormat(_timeFormat).format(DateTime.now());
    sp.setString("$_keyLastTokenRefreshTime$userId", lastTokenRefreshTime);
  }


   void invalidateTokens() {
    setRefreshToken("");
    setToken("");
    tokenIsValid = false;
  }

   bool tokenInvalidated() {
    return !tokenIsValid;
  }
}



class AccountManager{
  static const String _keyCurrentUserId = "_key_currentUserId";

  static int currentUserId;

  static HazizzAccount currentHazizzAccount;

  static Future<HazizzAccount> getCurrent() async {
    if(currentUserId == null) {
      getSp();
      String str_userKey = sp.getString(_keyCurrentUserId);
      if(str_userKey != null) {
        currentUserId = int.parse(str_userKey);
      }else{
        return null;
      }
    }
    return HazizzAccount(userId: currentUserId);
  }

  static Future<void> setCurrent({@required userId}) async {
    getSp();
    currentUserId = userId;
    sp.setString(_keyCurrentUserId, currentUserId.toString());
  }
}

*/


class TokenManager {

  static const String _keyToken = "key_token";
  static const String _keyRefreshToken = "key_refreshToken";
  static bool tokenIsValid = true;

  SharedPreferences prefs;



  static Future<HazizzResponse> createTokenWithPassword(@required String username, @required String password) async{
    HazizzResponse hazizzResponse = await RequestSender().getResponse(new CreateToken.withPassword(q_username: username, q_password: password));
    if(hazizzResponse.isSuccessful){
      PojoTokens tokens = hazizzResponse.convertedData;

      InfoCache.setMyUsername(username);
      setTokens(tokens.token, tokens.refresh);

    }else if(hazizzResponse.isError){
    }

    return hazizzResponse;
  }

  static Future<HazizzResponse> createTokenWithRefresh() async{
    HazizzResponse hazizzResponse = await RequestSender().getAuthResponse(new CreateToken.withRefresh(q_username: await InfoCache.getMyUsername(), q_refreshToken: await getRefreshToken()));
    if(hazizzResponse.isSuccessful){
      PojoTokens tokens = hazizzResponse.convertedData;
      setTokens(tokens.token, tokens.refresh);
    }else if(hazizzResponse.hasPojoError){
      AppState.logout();
    }
    return hazizzResponse;
  }

  static Future<HazizzResponse> createTokenWithGoolgeOpenId(String openIdToken) async{
    HazizzResponse hazizzResponse = await RequestSender().getAuthResponse(new CreateToken.withGoogleAccount(q_openIdToken: openIdToken));
    if(hazizzResponse.isSuccessful){
      PojoTokens tokens = hazizzResponse.convertedData;
      await setTokens(tokens.token, tokens.refresh);
      AppState.logInProcedure(tokens: tokens);
    }else if(hazizzResponse.hasPojoError){

    }
    return hazizzResponse;
  }






  static Future<bool> hasToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(_keyToken);
    return !(token == null || token == "");
  }

  static Future<String> getToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /*
  static Future<void> fetchTokens(@required String username, @required String password) async{
    HazizzResponse hazizzResponse = await RequestSender().getResponse(new CreateToken.withPassword(q_username: username, q_password: password));
    if(hazizzResponse.isSuccessful){
      HazizzLogger.printLog("log: token: tokens set");

      PojoTokens tokens = hazizzResponse.convertedData;

      InfoCache.setMyUsername(username);
      setToken(tokens.token);
      setRefreshToken(tokens.refresh);
     // setTokenRefreshTime();
    }else if(hazizzResponse.isError){

      int errorCode = hazizzResponse.pojoError.errorCode;
      HazizzLogger.printLog("log: errorCode: $errorCode");
      if(ErrorCodes.INVALID_PASSWORD.equals(errorCode)){
        throw new WrongPasswordException();
      }else if(ErrorCodes.USER_NOT_FOUND.equals(errorCode)){
        throw new WrongUsernameException();
      }
    }
    HazizzLogger.printLog("log: fetch token: done");
  }

  static Future<void> fetchRefreshTokens() async{
    HazizzResponse hazizzResponse = await RequestSender().getAuthResponse(new CreateToken.withRefresh(q_username: await InfoCache.getMyUsername(), q_refreshToken: await getRefreshToken()));
    if(hazizzResponse.isSuccessful){
      PojoTokens tokens = hazizzResponse.convertedData;
    //  InfoCache.setMyUsername(username);
      setToken(tokens.token);
      setRefreshToken(tokens.refresh);
    //  setTokenRefreshTime();
      setLastTokenUpdateTime(DateTime.now());
    }else if(hazizzResponse.pojoError != null){
      AppState.logout();
    }
  }
  */

  static Future<String> getRefreshToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }


  static const String key_lastTokenUpdateTime = "key_lastTokenUpdateTime";

  static Future<DateTime> getLastTokenUpdateTime() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String str = prefs.getString(key_lastTokenUpdateTime);

    return DateTime.parse(str);

  }

  static Future<void> setLastTokenUpdateTime(DateTime lastTokenUpdateTime) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key_lastTokenUpdateTime, lastTokenUpdateTime.toString());
  }


  static void setTokens(String newToken, String newRefreshToken) async{
    setLastTokenUpdateTime(DateTime.now());
    setToken(newToken);
    setRefreshToken(newRefreshToken);
    HazizzLogger.printLog("HazizzLog: tokens updated and saved");
    HazizzLogger.addKeys("token", newToken);
    HazizzLogger.addKeys("refreshToken", newRefreshToken);
  }


  static void setToken(String newToken) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyToken, newToken);
  }
  static void setRefreshToken(String newRefreshToken) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyRefreshToken, newRefreshToken);
  }

  static Future<bool> hasRefreshToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString(_keyRefreshToken);
    return !(refreshToken == null || refreshToken == "");
  }

  static const String _keyLastTokenRefreshTime = "key_LastTokenRefreshTime";
  static const String _timeFormat = "dd/MM/yyyy HH:mm:ss";

  static Future checkAndFetchTokenRefreshIfNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String str_lastTokenRefreshTime = prefs.getString(_keyLastTokenRefreshTime);
    if(str_lastTokenRefreshTime != null){
      DateTime lastTokenRefreshTime = DateFormat(_timeFormat).parse(_keyLastTokenRefreshTime);//DateTime.parse(str_lastTokenRefreshTime);
      if(lastTokenRefreshTime != null &&
        DateTime.now().difference(lastTokenRefreshTime).inSeconds.abs() >= 24*60*60)
      {
        createTokenWithRefresh();
      }
    }
  }

  static Future<bool> checkIfTokenRefreshIsNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String str_lastTokenRefreshTime = prefs.getString(_keyLastTokenRefreshTime);
    if(str_lastTokenRefreshTime != null && str_lastTokenRefreshTime != ""){
      DateTime lastTokenRefreshTime = DateFormat(_timeFormat).parse(str_lastTokenRefreshTime);//DateTime.parse(str_lastTokenRefreshTime);
      if(lastTokenRefreshTime != null &&
          DateTime.now().difference(lastTokenRefreshTime).inSeconds.abs() >= 24*60*60)
      {
        return false == false;
      }
    }
    return false;
  }

  /*
  static Future fetchToken() async {
    await fetchRefreshTokens(username: await InfoCache.getMyUsername(), refreshToken: await getRefreshToken());
  }
  */

  /*
  static Future setTokenRefreshTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastTokenRefreshTime = DateFormat(_timeFormat).format(DateTime.now());
    prefs.setString(_keyLastTokenRefreshTime, lastTokenRefreshTime);
  }
  */


  static void invalidateTokens() {
    setRefreshToken("");
    setToken("");
    tokenIsValid = false;
  }

  static bool tokenInvalidated() {
    return !tokenIsValid;
  }
}