import 'dart:convert';

import 'package:flutter_hazizz/communication/pojos/Pojo.dart';
import 'package:flutter_hazizz/communication/pojos/PojoSubject.dart';
import 'package:flutter_hazizz/communication/pojos/PojoType.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hazizz/communication/ResponseHandler.dart';
import 'package:flutter_hazizz/communication/pojos/PojoError.dart';
import 'package:flutter_hazizz/communication/pojos/task/PojoTask.dart';
import 'package:flutter_hazizz/communication/requests/request_collection.dart';

import '../RequestSender.dart';

class ViewTaskPage extends StatefulWidget {
  // This widget is the root of your application.

  int taskId;
  PojoTask pojoTask;

  ViewTaskPage({Key key, this.taskId}) : super(key: key);

  ViewTaskPage.fromPojo({Key key, this.pojoTask}) : super(key: key){
    taskId = pojoTask.id;
  }

  @override
  _ViewTaskPage createState() => _ViewTaskPage();
}

class _ViewTaskPage extends State<ViewTaskPage> {

  final TextEditingController _subjectTextEditingController = TextEditingController();
  final TextEditingController _groupTextEditingController = TextEditingController();
  final TextEditingController _creatorTextEditingController = TextEditingController();
  final TextEditingController _taskTypeTextEditingController = TextEditingController();
  final TextEditingController _deadlineTextEditingController = TextEditingController();
  final TextEditingController _descriptionTextEditingController = TextEditingController();
  final TextEditingController _titleTextEditingController = TextEditingController();

   String _subject = "";
   String _group = "";
   String _creator = "";
   String _type = "";
   String _deadline = "";
   String _description = "";
   String _title = "";

  List<PojoTask> task_data = List();

  void processData(PojoTask pojoTask){
    widget.pojoTask = pojoTask;
    setState(() {
      _subject = pojoTask.subject != null ? pojoTask.subject.name : null;
      _group = pojoTask.group.name;

      _creator = pojoTask.creator.displayName;

      _type = pojoTask.type.name;
      DateTime date_deadline =  pojoTask.dueDate;
      _deadline = DateFormat("yyyy.MM.dd").format(date_deadline);//"${date_deadline.day}.${date_deadline.month}.${date_deadline.year}";
      _description = pojoTask.description;
      _title = pojoTask.title;
    });
  }

  // lényegében egy onCreate
  @override
  void initState() {
    getData();
    if(widget.pojoTask != null) {
      processData(widget.pojoTask);
    }

    super.initState();
  }

  void getData() async{
 //   RequestSender()

    Response response = await RequestSender().send(new GetTaskByTaskId(
        p_taskId: widget.taskId,
        rh: new ResponseHandler(
            onSuccessful: (dynamic data) async{
            //  print("raw response is : ${response.data}" );

              PojoTaskDetailed pojoTask = data;

              processData(pojoTask);

            },
            onError: (PojoError pojoError){
              print("log: the annonymus functions work and the errorCode : ${pojoError.errorCode}");
            }
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: "hero_task${widget.pojoTask.id}",
        child: Scaffold(
        appBar: AppBar(
          title: Text("View Task"),
        ),
        body:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
        //    color: ,
           /* shape: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(93, 216, 105, 1),
                  style: BorderStyle.solid,
                  width: 4
                )),
                */

            elevation: 100,
            child: new RefreshIndicator(
              onRefresh: (){
                getData();
              },
              child: new Container(
                  child: new Column(
                   //   mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: PojoType.getColor(widget.pojoTask.type),
                      //  width: 400,

                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Flexible(
                                      child: Text(_type,
                                        style: TextStyle(
                                          fontSize: 36
                                        ),)
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10),                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  new Flexible(
                                      child: Text(_creator,
                                        style: TextStyle(
                                            fontSize: 18
                                        ),)
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  new Flexible(
                                      child: Text(_deadline,
                                        style: TextStyle(
                                            fontSize: 18
                                        ),)
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                        ),
                      _subject != null ?
                      Padding(
                        padding: const EdgeInsets.only( left: 10,top: 5),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Flexible(
                              child:
                              new Text(_subject,
                                style: TextStyle(
                                    fontSize: 36
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                      : Container(),
                      Padding(
                        padding: const EdgeInsets.only( left: 10,top: 5),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            new Flexible(
                              child: new Text(_title,
                                  style: TextStyle(
                                  fontSize: 30
                              ),
                            ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only( left: 20, right: 20, top: 4),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            new Flexible(
                                child:
                                Text(_description,
                                  style: TextStyle(
                                      fontSize: 26
                                  ),
                                )

                              )
                          ],
                        ),
                      ),

                      Expanded(
                       // flex: 1,
                        child:
                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                MaterialButton(
                                  onPressed: (){

                                  },
                                  child: Text("Comment"),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                 // crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    MaterialButton(
                                      onPressed: (){

                                      },
                                      child: Text("Edit"),
                                    ),
                                    MaterialButton(
                                      onPressed: (){

                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )

                      ),

                    ]
                  ),
              )
            ),
          ),
        )
      )
    );
  }

  Future<Null> _handleRefresh() async{
    await getData();

    var now = new DateTime.now();
    var berlinWallFell = new DateTime.utc(1989, 11, 9);
    var moonLanding = DateTime.parse("1969-07-20 20:18:04Z");  // 8:18pm



  }
}


/*new Flexible(
                    child: new Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.blueAccent)),
                      child: new TextField(
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),*/


/*new Flexible(
                    child: new Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.blueAccent)),
                      child: new TextField(
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),*/