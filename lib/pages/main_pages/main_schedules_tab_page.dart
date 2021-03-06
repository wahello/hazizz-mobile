import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/kreta/schedule_bloc.dart';
import 'package:mobile/blocs/main_tab/main_tab_blocs.dart';
import 'package:mobile/communication/pojos/PojoClass.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/listItems/class_item_widget.dart';
import 'package:mobile/widgets/ad_widget.dart';
import 'package:mobile/widgets/schedule_event_widget.dart';
import 'package:mobile/widgets/scroll_space_widget.dart';

import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/custom/hazizz_time_of_day.dart';

class SchedulesTabPage extends StatefulWidget {

  List<PojoClass> classes;

  bool noClasses = false;
  bool isToday = false;

  int dayIndex;

  SchedulesTabPage({Key key, @required this.classes, this.isToday = false, this.dayIndex}) : super(key: key);

  SchedulesTabPage.noClasses({Key key,this.isToday = false}) : super(key: key){
    noClasses = true;
  }

  @override
  _SchedulesTabPage createState() => _SchedulesTabPage();
}

class _SchedulesTabPage extends State<SchedulesTabPage> with TickerProviderStateMixin {

  HazizzTimeOfDay now = HazizzTimeOfDay.now();


  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  int currentEventIndex = 0;

  void updateTime(){
    setState(() {
      now = HazizzTimeOfDay.now();
    });
  }

  void updateEveryMinute(){
    Timer(Duration(minutes: 1), () {
      if(this.mounted) {
        updateTime();
        updateEveryMinute();
      }
    });
  }


  void scrollTo({int index}){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(index != null) currentEventIndex = index;
      print("scrolling: $currentEventIndex");
      itemScrollController.scrollTo(
        index: currentEventIndex,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic
      );
      print("scrolling: $currentEventIndex yes");

    });
  }

  @override
  void initState() {



    WidgetsBinding.instance.addPostFrameCallback((_){
      if(mounted){
        setState(() {
          updateEveryMinute();
        });
      }
      scrollTo();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.noClasses){
      return Stack(
        children: <Widget>[
          Center(child: Text(locText(context, key: "no_classes_today"))),
          Builder(
            builder: (context){
              if(MainTabBlocs().schedulesBloc.currentDayIndex >= 5) {
                return Positioned(
                  right: 0, bottom: 10,
                  child: FlatButton(
                    child: Row(
                      children: <Widget>[
                        Text(
                            locText(context, key: "next_week").toLowerCase()),
                        Icon(FontAwesomeIcons.chevronRight)
                      ],
                    ),
                    onPressed: () {
                      MainTabBlocs().schedulesBloc.dispatch(
                        ScheduleFetchEvent(
                          yearNumber: MainTabBlocs().schedulesBloc.currentYearNumber,
                          weekNumber: MainTabBlocs().schedulesBloc.currentWeekNumber + 1
                      ));
                    },
                  )
                );
              }
              return Container();
            },
          )
        ],
      );
    }

    HazizzLogger.printLog("it is today: ${widget.isToday}");

    List<Widget> listItems = [];

    for(PojoClass c in widget.classes){
      listItems.add(ClassItemWidget(pojoClass: c));
    }


    if(widget.isToday){
      // megnézi az időt
      for(int i = 0; i < widget.classes.length; i++){

        PojoClass previousClass = i-1 >= 0 ? widget.classes[i-1]:  null;
        PojoClass currentClass = widget.classes[i];
        PojoClass nextClass = i+1 <= widget.classes.length-1 ? widget.classes[i+1]: null;

        if(currentClass.startOfClass <= now && currentClass.endOfClass > now){
          /// megy az óra

          listItems[i] = ClassItemWidget.isCurrentEvent(pojoClass: widget.classes[i],);
          scrollTo(index: i);
        }
        else if(currentClass.startOfClass > now && previousClass == null){
          /// óra elött, nem kezdödött el a suli
          listItems.insert(0, ScheduleEventWidget.beforeClasses(context, currentClass.startOfClass));
          i = 0;//i-1;
          scrollTo(index: i);
          break;
        }

        else if(currentClass.startOfClass > now && previousClass.endOfClass < now){
          /// óra elött
          listItems.insert(i-1, ScheduleEventWidget.breakTime(context, currentClass.startOfClass));
          i = i-1;
          scrollTo(index: i);
          break;
        }
        else if(currentClass.endOfClass < now && nextClass == null){
          /// óra után, sulinak vége
          listItems.insert(i+1,ScheduleEventWidget.afterClasses(context));
          i = i+1;
          scrollTo(index: i);
          break;
        }
        else if(currentClass.endOfClass < now && nextClass.startOfClass > now){
          /// óra után
          listItems.insert(i+1, ScheduleEventWidget.breakTime(context, nextClass.startOfClass));
          i = i+1;
          scrollTo(index: i);
          break;
        }
      }
    }
    int itemCount = listItems.length+1;
    return ScrollablePositionedList.separated(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionListener,
      itemCount: itemCount,
      separatorBuilder: (context, index){
        return Container();
      },
      itemBuilder: (context, index){

        bool a = widget.dayIndex % 2  == 0 && index == itemCount-1;
      /*  if(index == itemCount-1){
          return addScrollSpace(showAd(context, show: widget.dayIndex % 2  == 0), space: widget.isToday ? (currentEventIndex+1) * 46.0 : 70);
        }else if(index == itemCount-1){
          return addScrollSpace(c, space: widget.isToday ? (currentEventIndex+1) * 46.0 : 70);
        }
        */

        if(index == itemCount-1){
          return addScrollSpace(showAd(context, show: widget.dayIndex % 2  == 0), space: widget.isToday ? (currentEventIndex+1) * 46.0 : 70);
        }
        return listItems[index];
    });
  }
}


