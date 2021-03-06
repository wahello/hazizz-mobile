import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/kreta/grades_bloc.dart';
import 'package:mobile/blocs/kreta/kreta_notes_bloc.dart';
import 'package:mobile/blocs/kreta/kreta_statistics_bloc.dart';
import 'package:mobile/blocs/main_tab/main_tab_blocs.dart';
import 'package:mobile/blocs/other/request_event.dart';
import 'package:mobile/blocs/other/response_states.dart';
import 'package:mobile/communication/pojos/PojoGrade.dart';
import 'package:mobile/communication/pojos/PojoGradeAvarage.dart';
import 'package:mobile/communication/pojos/PojoKretaNote.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/listItems/grade_item_widget.dart';
import 'package:mobile/widgets/hazizz_back_button.dart';

import 'package:mobile/listItems/note_item_widget.dart';

class KretaStatisticsPage extends StatefulWidget {

  @override
  _KretaStatisticsPage createState() => _KretaStatisticsPage();
}

class _KretaStatisticsPage extends State<KretaStatisticsPage> {

  KretaGradeStatisticsBloc gradeAvaragesBloc = KretaGradeStatisticsBloc();

  @override
  void initState() {
    gradeAvaragesBloc.dispatch(KretaGradeStatisticsFetchEvent());
    super.initState();
  }

  String selectedSubject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          leading: HazizzBackButton(),
          title: Text(locText(context, key: "kreta_grade_statistics")),
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            gradeAvaragesBloc.dispatch(KretaGradeStatisticsFetchEvent());
          },
          child: Stack(
            children: <Widget>[
              ListView(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      BlocBuilder(
                        bloc: MainTabBlocs().gradesBloc,
                        builder: (context, state){
                          if(MainTabBlocs().gradesBloc.grades != null && MainTabBlocs().gradesBloc.grades.grades.isNotEmpty){

                            if(selectedSubject == null){
                              selectedSubject = MainTabBlocs().gradesBloc.grades.grades.keys.toList()[0];
                            }

                            List<DropdownMenuItem> items = [];

                            for(String key in MainTabBlocs().gradesBloc.getGradesFromSession().grades.keys){
                              items.add(DropdownMenuItem(child: Text(key), value: key, ));
                            }
                            return Center(
                              child: DropdownButton(
                                value: selectedSubject,
                                onChanged: (item) {
                                  setState(() {
                                    selectedSubject = item;
                                  });
                                },
                                items: items
                              )
                            );
                          }
                          return Container();
                        },
                      ),
                      BlocBuilder(
                        bloc: gradeAvaragesBloc,
                        builder: (context, state){
                          if(state is KretaGradeStatisticsLoadedState && selectedSubject != null &&  gradeAvaragesBloc.gradeAvarages.isNotEmpty){
                            PojoGradeAvarage avarage = gradeAvaragesBloc.gradeAvarages.firstWhere((element) => element.subject == selectedSubject, orElse: () => null);
                            if(avarage != null){
                              return Padding(
                                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 6),
                                child: Container(
                                  width: 200,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("${locText(context, key: "average")}:", style: TextStyle(fontSize: 18),),
                                          Text(avarage.grade.toString(), style: TextStyle(fontSize: 18),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("${locText(context, key: "class_average")}:", style: TextStyle(fontSize: 18),),
                                          Text(avarage.classGrade.toString(), style: TextStyle(fontSize: 18),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("${locText(context, key: "difference")}:", style: TextStyle(fontSize: 18),),
                                          avarage.difference >= 0 ?
                                          Text("+${avarage.difference.toString()}", style: TextStyle(color: Colors.green, fontSize: 18),) :
                                          Text(avarage.difference.toString(), style: TextStyle(color: Colors.red, fontSize: 18))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: BlocBuilder(
                      bloc: MainTabBlocs().gradesBloc,
                      builder: (context, state){
                        Widget buildItem(){
                          List<PojoGrade> grades = MainTabBlocs().gradesBloc.getGradesFromSession().grades[selectedSubject];

                          if(grades == null || grades.isEmpty){
                            return Center(child: Text(locText(context, key: "no_grades_yet")));
                          }
                          return new ListView.builder(
                            itemCount: grades.length,
                            itemBuilder: (BuildContext context, int index) {

                              return GradeItemWidget.bySubject(pojoGrade: grades[index],);
                            }
                          );
                        }
                        if(state is GradesLoadedState){
                          return buildItem();
                        }else if(state is GradesLoadedCacheState){
                          return buildItem();
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}


