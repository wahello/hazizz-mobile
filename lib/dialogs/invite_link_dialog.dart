import 'package:flutter/material.dart';

import 'package:mobile/communication/pojos/PojoGroup.dart';
import 'package:mobile/communication/pojos/PojoInviteLink.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/enums/group_types_enum.dart';
import 'package:share/share.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/communication/request_sender.dart';
import 'dialogs.dart';

class InviteLinkDialog extends StatefulWidget {

  PojoGroup group;

  InviteLinkDialog({Key key, @required this.group}){

  }

  @override
  _InviteLinkDialog createState() => new _InviteLinkDialog();
}

class _InviteLinkDialog extends State<InviteLinkDialog> {

  String inviteLink;

  static const String errorText = "error";

  @override
  void initState() {

    RequestSender().getResponse(GetGroupInviteLinks(groupId: widget.group.id)).then((hazizzResponse){
      setState(() {
        if(hazizzResponse.isSuccessful){

          List<PojoInviteLink> links = hazizzResponse.convertedData;
          inviteLink = links[0].link;

        }else{
          inviteLink = errorText;
        }
      });

    });

    super.initState();
  }

  bool passwordVisible = true;

  GroupType groupValue = GroupType.OPEN;


  final double width = 300;
  final double height = 175;

  final double searchBarHeight = 50;


  @override
  Widget build(BuildContext context) {



    HazizzDialog h = HazizzDialog(
        header:
        Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(locText(context, key: "invite_link_info", args: [widget.group.name]), style: TextStyle(fontSize: 19),),
            )
        ),
        content: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(builder: (context){
                if(inviteLink != null ){
                  return Text(inviteLink, style: TextStyle(fontSize: 15));
                }else if(inviteLink == errorText){
                  return Text(locText(context, key: "info_something_went_wrong"), style: TextStyle(fontSize: 15));
                }
                return Center(child: Text(locText(context, key: "loading"), style: TextStyle(fontSize: 20),));
              })
            ),
        ),
        actionButtons:
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                child: Center(
                  child: Text(
                    locText(context, key: "cancel").toUpperCase(),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.transparent
            ),
            FlatButton(
                child: Center(
                  child: Text(locText(context, key: "share").toUpperCase(),),
                ),
                onPressed: () {
                  HazizzLogger.printLog("pressed share button");

                  Share.share(locText(context, key: "invite_to_group_text_title", args: [widget.group.name, inviteLink]));
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                },
                color: Colors.transparent
            ),
          ],
        ) ,height: 190,width: 200);
    return h;
  }
}