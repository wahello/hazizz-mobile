import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:mobile/blocs/flush_bloc.dart';
import 'package:mobile/blocs/kreta/new_grade_bloc.dart';
import 'package:mobile/blocs/kreta/selected_session_bloc.dart';

import 'package:mobile/blocs/other/request_event.dart';
import 'package:mobile/blocs/other/response_states.dart';
import 'package:mobile/communication/connection.dart';
import 'package:mobile/communication/custom_response_errors.dart';
import 'package:mobile/communication/pojos/PojoGrade.dart';
import 'package:mobile/communication/pojos/PojoGrades.dart';
import 'package:mobile/communication/pojos/PojoSession.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/enums/grades_sort_enum.dart';
import 'package:mobile/communication/hazizz_response.dart';
import 'package:mobile/communication/request_sender.dart';
import 'package:mobile/services/selected_session_helper.dart';
import 'package:mobile/storage/caches/data_cache.dart';

//region Grades bloc parts
//region Grades events
abstract class GradesEvent extends HEvent {
  GradesEvent([List props = const []]) : super(props);
}

class GradesSetSessionEvent extends GradesEvent {
  GradesSetSessionEvent() :  super([DateTime.now()]);
  @override
  String toString() => 'GradesSetSessionEvent';
  List<Object> get props => null;

}

class GradesFetchEvent extends GradesEvent {
  final bool retry;

  GradesFetchEvent({this.retry = false}) :  super();
  @override
  String toString() => 'GradesFetchEvent';
  List<Object> get props => null;
}
//endregion

//region Grades states
abstract class GradesState extends HState {
  GradesState([List props = const []]) : super(props);
}

class GradesInitialState extends GradesState {
  @override
  String toString() => 'GradesInitialState';
  List<Object> get props => null;
}

class GradesWaitingState extends GradesState {
  @override
  String toString() => 'GradesWaitingState';
  List<Object> get props => null;
}

class GradesLoadedState extends GradesState {
  PojoGrades data;

  final List<PojoSession> failedSessions;

  GradesLoadedState(this.data, { this.failedSessions }) : assert(data!= null), super([data, SelectedSessionBloc().selectedSession]){
    if(data == null){
      print("WRONG!!!");
    }
    data ??= PojoGrades({});
  }
  @override
  String toString() => 'GradesLoadedState';
  List<Object> get props => [data, SelectedSessionBloc().selectedSession];
}

class GradesLoadedCacheState extends GradesState {
  PojoGrades data;

  final List<PojoSession> failedSessions;

  GradesLoadedCacheState(this.data,  { this.failedSessions }) : assert(data!= null), super([data, SelectedSessionBloc().selectedSession]){
    data ??= PojoGrades({});
  }
  @override
  String toString() => 'GradesLoadedCacheState';
  List<Object> get props => [data, SelectedSessionBloc().selectedSession];
}
/*
class GradesSessionFailedState extends GradesState {
  PojoGrades data;
  GradesSessionFailedState(this.data) : assert(data!= null), super([data, SelectedSessionBloc().selectedSession]){
    data ??= PojoGrades({});
  }
  @override
  String toString() => 'GradesLoadedCacheState';
  List<Object> get props => [data, SelectedSessionBloc().selectedSession];
}
*/

class GradesErrorState extends GradesState {
  HazizzResponse hazizzResponse;
  GradesErrorState(this.hazizzResponse) : assert(hazizzResponse!= null), super([hazizzResponse]);

  @override
  String toString() => 'GradesErrorState';
  List<Object> get props => [hazizzResponse];
}


//endregion

//region Grades bloc
class GradesBloc extends Bloc<GradesEvent, GradesState> {

  List<PojoSession> failedSessions = [];

  GradesSort currentGradeSort = GradesSort.BYCREATIONDATE;
  GradesBloc();

  int _failedRequestCount = 0;

  DateTime lastUpdated = DateTime(0, 0, 0, 0, 0);

  PojoGrades grades;
  List<PojoGrade> gradesByDate = List();

  PojoGrades getGradesFromSession(){
    Map<String, List<PojoGrade>> sessionGrades = {};
    for(String key in grades.grades.keys){
      int newI = 0;
      for(int i = 0; i < grades.grades[key].length; i++){
        if(grades.grades[key][i].accountId?.split("_")[2] == SelectedSessionBloc().selectedSession?.username){
          if(sessionGrades[key] == null){
            sessionGrades[key] = [];
          }
          sessionGrades[key].insert(newI, grades.grades[key][i]);
          newI++;
        }
      }
    }
    return PojoGrades(sessionGrades);
  }

  List<PojoGrade> getGradesByDateFromSession(){
    gradesByDate = getGradesByDate();
    List<PojoGrade> sessionGradesByDate = [];
    for(PojoGrade g in gradesByDate){
      if(g.accountId?.split("_")[2] == SelectedSessionBloc().selectedSession?.username){
        sessionGradesByDate.add(g);
      }
    }
    return sessionGradesByDate;
  }


  @override
  GradesState get initialState => GradesInitialState();

  List<PojoGrade> getGradesByDate(){
    gradesByDate.clear();


    if(grades != null && grades.grades != null){
      HazizzLogger.printLog("Grades sub1: ${grades.grades.values.length}");
      for(int i = 0; i < grades.grades.values.length; i++){
        HazizzLogger.printLog("Grades sub2: ${grades.grades.values.toList()[i]}");
        gradesByDate.addAll(grades.grades.values.toList()[i]);
      }
      HazizzLogger.printLog("Grades sub LENGTH: ${gradesByDate.length}");

      if(currentGradeSort == GradesSort.BYCREATIONDATE) {
        gradesByDate.sort((a, b) => a.compareToByCreationDate(b));
      }else{
        gradesByDate.sort((a, b) => a.compareToByDate(b));
      }
    }
    return gradesByDate;
  }

  String calculateAvarage(List<PojoGrade> pojoGrades){
    double gradeAmount = 0;
    double gradeSum = 0;
    for(PojoGrade pojoGrade in pojoGrades){
      if(pojoGrade != null && pojoGrade.grade != null && pojoGrade.weight != null){
        try {
          int grade = int.parse(pojoGrade.grade);
          int weight = pojoGrade.weight;

          if(grade != null) {
            double gradeWeightCurrent = weight / 100;
            gradeAmount += gradeWeightCurrent;
            gradeSum += gradeWeightCurrent * grade;
          }
        }catch(e){

        }
      }
    }
    if(gradeSum != 0 && gradeAmount != 0){

      int decimals = 2;
      int fac = pow(10, decimals);
      double d = gradeSum/gradeAmount;
      d = (d * fac).round() / fac;
      return d.toString();
    }
    return "";
  }


  @override
  Stream<GradesState> mapEventToState(GradesEvent event) async* {
    if(event is GradesSetSessionEvent){
      print("happended12");
      yield GradesLoadedState(grades, failedSessions: failedSessions);
    }
    else if (event is GradesFetchEvent) {
      try {
        /*
        if(true){
          grades = new PojoGrades(
              {"Matek TESZT" : [
                PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "1", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
                PojoGrade(creationDate: DateTime(2011), date: DateTime(2019), grade: "2", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 100),
                PojoGrade(creationDate: DateTime(2012), date: DateTime(2019), grade: "3", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 50),
                PojoGrade(creationDate: DateTime(2013), date: DateTime(2019), grade: "1", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200)],

                "Történelem TESZT" : [
                  PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 100),
                  PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "3", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
                  PojoGrade(creationDate: DateTime(2011), date: DateTime(2019), grade: "2", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 50),
                  PojoGrade(creationDate: DateTime(2012), date: DateTime(2019), grade: "4", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 100)],

                "Komplex Természet Tudomány" : [
              PojoGrade(creationDate: DateTime(2011), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2012), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2032), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 600)]

              ,"Komplex Természet Tudomány2" : [
              PojoGrade(creationDate: DateTime(2011), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2012), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2032), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 600)]
              ,"Komplex Természet Tudomány3" : [
              PojoGrade(creationDate: DateTime(2011), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2012), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2032), date: DateTime(2019), grade: "3", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 200),
              PojoGrade(creationDate: DateTime(2010), date: DateTime(2019), grade: "5", gradeType: "teszt jegy", subject: "Nyelvtan Teszt", topic: "Ez csak teszt", weight: 600)]

              }
          );
          yield GradesLoadedState(grades);
          return;
        }
        */

        yield GradesWaitingState();
        HazizzLogger.printLog("log: am0 i here?");

        DataCache dataCache = await loadGradesCache();
        if(dataCache!= null){
          lastUpdated = dataCache.lastUpdated;
          grades = dataCache.data ?? PojoGrades({});
          yield GradesLoadedCacheState(grades);
        }
        HazizzResponse hazizzResponse = await getResponse(
          KretaGetGrades(),
          useSecondaryOptions: event.retry
        );
        print("CHANGE HAPPENDE03");
        if(hazizzResponse.isSuccessful){
          failedSessions = getFailedSessionsFromHeader(hazizzResponse.response.headers);

          /*
          if(doesContainSelectedSession(failedSessions)){
            print("doesContainSelectedSession");
            FlushBloc().dispatch(FlushSessionFailEvent());
            print("doesContainSelectedSession0");

           // yield GradesSessionFailedState(grades ?? PojoGrades({}));
            print("doesContainSelectedSession1");

          //  yield GradesLoadedState(grades, failedSessions: failedSessions);
          //  print("doesContainSelectedSession2");

          }
          */
          print("testgst:0");

          if(hazizzResponse.convertedData != null){
            print("testgst:1");
            PojoGrades r = hazizzResponse.convertedData;
            if(r.grades.isNotEmpty){
              grades = r;
              print("CHANGE HAPPENDE01");
              PojoGrades oldGrades = dataCache?.data;

              if(oldGrades == null || grades.grades.toString() != oldGrades.grades.toString()){
                print("CHANGE HAPPENDE1");
                NewGradesBloc().dispatch(HasNewGradesEvent());

                for(String key in oldGrades.grades.keys){
                  for(PojoGrade g1 in oldGrades.grades[key]){
                    for(PojoGrade g2 in grades.grades[key]){
                      if(g1 == g2){
                        g2.isNew = true;
                        break;
                      }
                    }
                  }
                }

              }else{
                print("CHANGE HAPPENDE2");
              }

              lastUpdated = DateTime.now();
              saveGradesCache(grades);
              print("happended122");

              yield GradesLoadedState(grades, failedSessions: failedSessions);
            }else{
              print("testgst:2");

              yield GradesLoadedCacheState(grades ?? PojoGrades({}), failedSessions: failedSessions);
            }
            print("testgst:3");


          }else{
            print("testgst:4");

           // yield GradesErrorState(hazizzResponse);
          }
          print("testgst:5");

        }
        print("testgst:6");


        if(hazizzResponse.isError){
          if(hazizzResponse.dioError == noConnectionError){
            yield GradesErrorState(hazizzResponse);
            Connection.addConnectionOnlineListener((){
              this.dispatch(GradesFetchEvent());
            },
                "grades_fetch"
            );
          }else if(hazizzResponse.dioError.type == DioErrorType.CONNECT_TIMEOUT
                || hazizzResponse.dioError.type == DioErrorType.RECEIVE_TIMEOUT) {
            print("here i am and im here to ");
            _failedRequestCount++;
            if(_failedRequestCount == 1) {
              this.dispatch(GradesFetchEvent());
            }else{
              yield GradesLoadedCacheState(grades);
            }

          } else if(hazizzResponse.hasPojoError && hazizzResponse.pojoError.errorCode == 138) {
            yield GradesErrorState(hazizzResponse);
          }

          else{
           // yield GradesErrorState(hazizzResponse);
          }
        }
      } on Exception catch(e){
        HazizzLogger.printLog("log: Exception: ${e.toString()}");
      }
    }
  }
}
//endregion
//endregion
