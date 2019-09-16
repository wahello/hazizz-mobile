import 'package:expandable/expandable.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/main_tab_blocs/main_tab_blocs.dart';
import 'package:mobile/blocs/request_event.dart';
import 'package:mobile/blocs/response_states.dart';
import 'package:mobile/blocs/schedule_bloc.dart';
import 'package:mobile/communication/errors.dart';
import 'package:mobile/communication/pojos/PojoClass.dart';
import 'package:mobile/communication/pojos/PojoSchedules.dart';
import 'package:mobile/custom/formats.dart';
import 'package:mobile/listItems/schedule_event_widget.dart';
import 'package:mobile/widgets/flushbars.dart';
import 'package:toast/toast.dart';

import '../../hazizz_localizations.dart';
import '../../logger.dart';
import '../kreta_service_holder.dart';
import 'main_schedules_tab_page.dart';

class SchedulesPage extends StatefulWidget {


  SchedulesPage({Key key}) : super(key: key);

  getTabName(BuildContext context){
    return locText(context, key: "schedule").toUpperCase();
  }

  @override
  _SchedulesPage createState() => _SchedulesPage();
}

class _SchedulesPage extends State<SchedulesPage> with TickerProviderStateMixin , AutomaticKeepAliveClientMixin {


  _SchedulesPage(){}

  TabController _tabController;
 // int _currentIndex;

  int currentDayIndex;

  List<SchedulesTabPage> _tabList = [];

  List<BottomNavigationBarItem> bottomNavBarItems = [];

  bool canBuildBottomNavBar = false;


  @override
  void initState() {
   // currentDayIndex = MainTabBlocs().schedulesBloc.currentDayIndex;
   // _currentIndex = currentDayIndex;

    /*
    if(schedulesBloc.currentState is ResponseError) {
      print("log: here233");
      schedulesBloc.dispatch(FetchData());
    }
    */

    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Widget selectedPage = Container();


  Widget onLoaded(PojoSchedules pojoSchedule){

    void addNoClassDay(String dayIndex){
      _tabList.add(SchedulesTabPage.noClasses());
      bottomNavBarItems.add(BottomNavigationBarItem(
        title: Container(),
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(locText(context, key: "days_m_$dayIndex"),
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w600, /*backgroundColor: currentDayColor*/),
          ),
        ),
        activeIcon: Text(locText(context, key: "days_$dayIndex"),
          overflow: TextOverflow.fade,
          maxLines: 1,
          style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold, /*backgroundColor: currentDayColor*/),
        ),
      ));
    }



    Map<String, List<PojoClass>> schedule = pojoSchedule.classes;

    Widget body;

    DateTime now = DateTime.now();

    DateTime weekStart = DateTime(now.year, now.month, now.day - now.weekday+1);

    DateTime weekEnd = DateTime(now.year, now.month, now.day + 7 - now.weekday);

    if(schedule.isEmpty){
      body = Center(child: Text(locText(context, key: "no_schedule_for_week")),);
    }else{
     /* if(MainTabBlocs().schedulesBloc.currentDayIndex > schedule.length-1){
        MainTabBlocs().schedulesBloc.currentDayIndex = schedule.length-1;
      }
      */

      _tabList.clear();
      bottomNavBarItems.clear();
      for(int day = 0; day <= 6; day++){ // String dayIndex in schedule.keys

        print("weekday: ${now.weekday}");

        print("nig: ${schedule.keys.toList()}, ");
        if(!schedule.keys.toList().contains(day.toString())) {
          print("illegal");
          if(day <= 4){
            addNoClassDay(day.toString());
          }else{
            if(now.weekday == 7 && day == 6){
              addNoClassDay((day-1).toString()); //szombat
              addNoClassDay(day.toString()); //vasárnap
            //  break;
            }else if(now.weekday == 6 && day == 5){
              addNoClassDay(day.toString()); // szombat
              if(now.weekday == 6){
                break;
              }
             // break;
            }
          }
        }
        else{
          String dayIndex = schedule.keys.toList()[day];

          if( schedule[dayIndex].isNotEmpty) {
            Color currentDayColor = Colors.transparent;

            String dayName = locText(context, key: "days_$dayIndex");
            String dayMName = locText(context, key: "days_m_$dayIndex");
            _tabList.add(SchedulesTabPage(classes: schedule[dayIndex]));
            bottomNavBarItems.add(BottomNavigationBarItem(
              title: Container(),
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(dayMName,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w600, /*backgroundColor: currentDayColor*/),
                ),
              ),
              activeIcon: Text(dayName,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold, /*backgroundColor: currentDayColor*/),
              ),
            ));
          }else{

          }
        }
      }

      print("yeehasw: ${ _tabList.length}, ${MainTabBlocs().schedulesBloc.todayIndex}");

      _tabController = TabController(vsync: this, length: _tabList.length, initialIndex: MainTabBlocs().schedulesBloc.todayIndex
      );

      if(canBuildBottomNavBar == false) {
        SchedulerBinding.instance.addPostFrameCallback((_) =>
            setState(() {
              if(this.mounted){
                canBuildBottomNavBar = true;
              }
            })
        );
      }


      /*

      WidgetsBinding.instance.addPostFrameCallback((_) =>
          setState(() {
            _tabController.animateTo(_tabController.index);
          })
      );
      */

      // now.weekday





      body =
          Column(
            children: <Widget>[
             /* Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: _tabList,
                ),
              ),
              */

              Expanded(child: _tabList[MainTabBlocs().schedulesBloc.currentDayIndex]),


              Builder(
                builder: (context){
                  if(canBuildBottomNavBar){
                    return Container(
                        color: Theme.of(context).primaryColorDark,
                        child: BottomNavigationBar(

                          currentIndex: MainTabBlocs().schedulesBloc.currentDayIndex,
                          onTap: (int index){
                            setState(() {
                              print("indexing1: ${MainTabBlocs().schedulesBloc.currentDayIndex}");
                              MainTabBlocs().schedulesBloc.currentDayIndex = index;
                              print("indexing2: ${MainTabBlocs().schedulesBloc.currentDayIndex}");
                              _tabController.animateTo(index);
                              print("indexing3: ${_tabController.index}");

                            });

                          },
                          items: bottomNavBarItems
                        )
                    );
                  }
                  return Container();
                },
              )
            ],
          );
    }

    /*
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Navigator.pushNamed(context, "/kreta/login/auth", arguments: widget.session)
    );
    */


    return Column(
      children: [
        /*
        Container(
          height: 100,
          child: DropdownMenu(
            menus: [
              Text("asd")
            ],
          ),
        ),
        */
        /*
        Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: ExpandablePanel(
              tapHeaderToExpand: true,
              collapsed: Container(
                width: MediaQuery.of(context).size.width,

                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(FontAwesomeIcons.chevronLeft),
                        onPressed: (){
                          MainTabBlocs().schedulesBloc.dispatch(ScheduleFetchEvent(yearNumber: MainTabBlocs().schedulesBloc.currentYearNumber, weekNumber: MainTabBlocs().schedulesBloc.currentWeekNumber-1));
                        },
                      ),
                      Text(MainTabBlocs().schedulesBloc.currentWeekNumber.toString()),

                    //  Text("${weekStart.day}-${weekEnd.day}"),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.chevronRight),
                        onPressed: (){
                          MainTabBlocs().schedulesBloc.dispatch(ScheduleFetchEvent(yearNumber: MainTabBlocs().schedulesBloc.currentYearNumber, weekNumber: MainTabBlocs().schedulesBloc.currentWeekNumber+1));
                        },
                      ),
                    ],
                  )
                ),
              ),
              expanded: Card(
                child: Column(
                  children: <Widget>[
                    Text("date"),
                    Text("date"),
                    Text("date"),
                  ],
                )
              ),
            ),
          ),
        ),
        */
        Text(dateTimeToLastUpdatedFormat(context, MainTabBlocs().schedulesBloc.lastUpdated)),
      //  Expanded(child: body),
        Expanded(child: body)
        // Container( width: MediaQuery.of(context).size.width,child: ScheduleEventWidget()),
      ]
    );

  }

  void previousWeek(){
    setState(() {

    });


    MainTabBlocs().schedulesBloc.dispatch(ScheduleFetchEvent(yearNumber: MainTabBlocs().schedulesBloc.currentYearNumber, weekNumber: MainTabBlocs().schedulesBloc.currentWeekNumber-1));

  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  ScheduleState lastState = ScheduleInitialState();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldState,

        body: KretaServiceHolder(
          child: BlocBuilder(
            bloc: MainTabBlocs().schedulesBloc,
            builder: (context, state){
              return RefreshIndicator(
                onRefresh: () async{
                  MainTabBlocs().schedulesBloc.dispatch(ScheduleFetchEvent());

                },
                child: Stack(
                    children: <Widget>[
                      ListView(),
                      Column(
                        children: <Widget>[
                          Card(
                            child: BlocBuilder(
                              bloc: MainTabBlocs().schedulesBloc,
                              builder: (_, state){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(FontAwesomeIcons.chevronLeft),
                                      onPressed: (){
                                        MainTabBlocs().schedulesBloc.previousWeek();
                                      },
                                    ),
                                    Text("${dateTimeToMonthDay(MainTabBlocs().schedulesBloc.currentWeekMonday)} - ${dateTimeToMonthDay(MainTabBlocs().schedulesBloc.currentWeekSunday)}", style: TextStyle(fontSize: 18),),

                                    //  Text("${weekStart.day}-${weekEnd.day}"),
                                    IconButton(
                                      icon: Icon(FontAwesomeIcons.chevronRight),
                                      onPressed: (){
                                        MainTabBlocs().schedulesBloc.nextWeek();                                      },
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder(
                                bloc:  MainTabBlocs().schedulesBloc,
                                condition: (ScheduleState beforeState, ScheduleState currentState){
                                  print("current state test");
                                //  print("current state is: ${currentState}");
                                //  print("last state is: ${beforeState}");


                                  if(beforeState is ScheduleLoadedState && currentState is ScheduleLoadedState){
                                    //return false;

                                  }


                                  return true;
                                },
                                builder: (_, ScheduleState state) {

                                  print("state is izé: ${state}");
                                  if (state is ScheduleWaitingState || (state is ScheduleLoadedCacheState && lastState is ScheduleWaitingState)) {
                                    //return Center(child: Text("Loading Data"));
                                    return Center(child: CircularProgressIndicator(),);
                                  }
                                  lastState = state;

                                  if (state is ScheduleLoadedState) {
                                    if(state.schedules != null /*&& state.data.isNotEmpty()*/){
                                      print("hát persze hogy eljutok1");
                                      return onLoaded(state.schedules);

                                    }
                                  }else if (state is ScheduleLoadedCacheState) {
                                    if(state.data != null /*&& state.data.isNotEmpty()*/){
                                      print("hát persze hogy eljutok2");
                                      return onLoaded(state.data);

                                    }                          }
                                  else if (state is ResponseEmpty) {
                                    return Column(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 50.0),
                                              child: Text(locText(context, key: "no_schedule")),
                                            ),
                                          )
                                        ]
                                    );
                                  }else if(state is ScheduleErrorState ){
                                    if(state.hazizzResponse.pojoError != null && state.hazizzResponse.pojoError.errorCode == 138){
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        showKretaUnavailableFlushBar(context, scaffoldState: scaffoldState);
                                      });
                                    }
                                    else if(state.hazizzResponse.dioError == noConnectionError){
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        showNoConnectionFlushBar(context, scaffoldState: scaffoldState);
                                      });
                                    }else{
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          Flushbar(
                                            icon: Icon(FontAwesomeIcons.exclamation, color: Colors.red,),

                                            message: "${locText(context, key: "schedule")}: ${locText(context, key: "info_something_went_wrong")}",
                                            duration: Duration(seconds: 3),
                                          );
                                        });
                                        // Toast.show(locText(context, key: "info_something_went_wrong"), context, duration: 4, gravity:  Toast.BOTTOM);
                                      });
                                    }

                                    if(MainTabBlocs().schedulesBloc.classes != null){
                                      return onLoaded(MainTabBlocs().schedulesBloc.classes);
                                    }
                                    return Center(
                                        child: Text(locText(context, key: "info_something_went_wrong")));
                                  }
                                  return Center(child: Text(locText(context, key: "info_something_went_wrong")),);

                                }
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
              );
            }
          )
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



