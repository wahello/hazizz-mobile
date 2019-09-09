import 'package:flutter/material.dart';

import '../hazizz_date.dart';

class GradeHeaderItemWidget extends StatelessWidget{
   String subjectName;

   String gradesAvarage;

  DateTime date;

  GradeHeaderItemWidget.bySubject({this.subjectName, this.gradesAvarage});

  GradeHeaderItemWidget.byDate({this.date});

  @override
  Widget build(BuildContext context) {



    return Card(
        margin: EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 2),

        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Theme.of(context).primaryColorDark,
        child: InkWell(
            child: Builder(builder: (context){
              if(date == null){
                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 2, bottom: 2),
                      child: Text(subjectName, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),),
                    ),
                    SizedBox(width: 20),
                    Padding(
                        padding: const EdgeInsets.only(left: 5.0, top: 2, bottom: 2),
                        child: Text(gradesAvarage, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700))
                    ),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 2, bottom: 2),
                    child: Text(hazizzShowDateFormat(date), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
                  ),
                ],
              );
            })
        )
    );
  }
}
