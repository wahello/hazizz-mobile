import 'package:flutter/material.dart';
import 'package:mobile/communication/pojos/PojoSubject.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/request_sender.dart';
import '../hazizz_localizations.dart';
import '../hazizz_response.dart';
import '../hazizz_theme.dart';
import 'dialogs.dart';

class SureToDeleteSubjectDialog extends StatefulWidget {

  int groupId;

  PojoSubject subject;

  SureToDeleteSubjectDialog({@required this.groupId, @required this.subject});

  @override
  _SureToDeleteSubjectDialog createState() => new _SureToDeleteSubjectDialog();
}

class _SureToDeleteSubjectDialog extends State<SureToDeleteSubjectDialog> {


  String groupName;

  bool isLoading = false;

  bool isMember = false;

  bool someThingWentWrong = false;

  @override
  void initState() {


    super.initState();
  }


  final double width = 300;
  final double height = 90;


  @override
  Widget build(BuildContext context) {

    var dialog = HazizzDialog(width: width, height: height,
        header: Stack(
          children: <Widget>[
            Container(
              width: width,
              height: height,
              color: HazizzTheme.red,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child:
                  Center(
                    child: Builder(builder: (context){
                      return Text(locText(context, key: "areyousure_delete_subject", args: [widget.subject.name]),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          )
                      );

                    }),
                  )
              ),
            ),
            Builder(builder: (context){
              if(isLoading){
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey.withAlpha(120),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Container();
            })

          ],
        ),
        content: Container(),
        actionButtons: Builder(builder: (context){

          return Row(children: <Widget>[
            FlatButton(
              child: Text(locText(context, key: "no").toUpperCase(),),
              onPressed: (){
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text(locText(context, key: "yes").toUpperCase(),),
              onPressed: () async {

                setState(() {
                  isLoading = true;
                });
                HazizzResponse hazizzResponse = await RequestSender().getResponse(DeleteSubject(p_groupId: widget.groupId, p_subjectId: widget.subject.id));

                if(hazizzResponse.isSuccessful){
                  Navigator.pop(context, true);
                }
                setState(() {
                  isLoading = false;
                });

              },
            )
          ],);

        })
    );
    return dialog;
  }
}