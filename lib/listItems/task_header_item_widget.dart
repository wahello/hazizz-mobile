import 'package:flutter/material.dart';

import 'package:mobile/custom/hazizz_date.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/theme/hazizz_theme.dart';
import 'package:mobile/widgets/card_header_widget.dart';

class TaskHeaderItemWidget extends StatelessWidget{
 // String days;
 // String date;
  DateTime dateTime;

  TaskHeaderItemWidget({Key key, this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    final diffTask = dateTime.difference(new DateTime(dateTime.year, 1, 1, 0, 0));
    final int daysTask = diffTask.inDays;

    final diffNow = DateTime.now().difference(new DateTime(dateTime.year, 1, 1, 0, 0));
    final int daysNow = diffNow.inDays;
    */
    Duration d = dateTime.difference(DateTime.now().subtract(Duration(days: 1)));
    int days = d.inDays;

   // int days = daysTask - daysNow;

    Color backColor;

    String title;
    if(days == 0){
      backColor = HazizzTheme.yellow;
      title = locText(context, key: "today");
    }else if(days == 1){
      title = locText(context, key: "tomorrow");
    }else if(days < 0){
      title = locText(context, key: "days_ago", args: [days.abs().toString()]);
      backColor = HazizzTheme.red;
    }

    else{
      title = locText(context, key: "days_later", args: [days.toString()]);
    }
    return CardHeaderWidget(
      text: title,
      secondText: hazizzShowDateFormat(dateTime),
      backgroundColor: backColor,
    );
  }
}
