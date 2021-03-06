import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:mobile/custom/hazizz_logger.dart';

class Connection{

  static StreamSubscription streamConnectionStatus;
  static ConnectivityResult connectivity;

  static Future<Null> listener() async {
    streamConnectionStatus = new Connectivity()
        .onConnectivityChanged.listen((ConnectivityResult result) {
      HazizzLogger.printLog(result.toString());
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        // hasConnection = true;
        HazizzLogger.printLog("Connection: available");
        listeners.forEach((k,v) => v());


        listeners.clear();


      } else {
        // hasConnection = false;
        HazizzLogger.printLog("Connection: not available");

        //  lock();
      }
    });
  }

  static Map<String, Function> listeners = Map();

  static void addConnectionOnlineListener(Function listener, String identifier){
    listeners[identifier] = listener;
    HazizzLogger.printLog("Added Connection listener: ${identifier}");
  }


  static Future<bool> isOnline() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.mobile) {
      return true;
    }else if(connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static Future<bool> isOffline() async{
    return !(await isOnline());
  }



}