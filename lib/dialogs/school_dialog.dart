import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mobile/custom/hazizz_localizations.dart';
import 'dialogs.dart';

class SchoolDialog extends StatefulWidget {

  final Map data;
  final Function({String key, String value}) onPicked;

  SchoolDialog({@required this.onPicked, @required this.data});

  @override
  _SchoolDialog createState() => new _SchoolDialog();
}

class _SchoolDialog extends State<SchoolDialog> {

  List<String> keys;
  List<dynamic> values;

  List<String> searchKeys;

  Map searchData;

  _SchoolDialog(){
  }

  @override
  void initState() {
    keys = widget.data.keys.toList();
    values = widget.data.values.toList();

    searchKeys = keys;

    searchData = widget.data;

    super.initState();
  }
  
  TextEditingController searchController;

  final double width = 400;
  final double height = 500;

  final double searchBarHeight = 50;
  @override
  Widget build(BuildContext context) {

    var dialog = HazizzDialog(width: width, height: height,
      header: Container(
        height: searchBarHeight, width: width,
        child:
          TextField(
            autofocus: true,
            style: TextStyle(fontSize: 20),
              onChanged: (String searchText){
                //   List<String> searchKeys = keys;

                List<String> nextSearchKeys = List();
                for(String s in keys){
                  if(s.toLowerCase().contains(searchText.toLowerCase())){
                    nextSearchKeys.add(s);
                  }
                }
                setState((){
                  searchKeys = nextSearchKeys;
                });
              },
              controller: searchController,
              decoration: InputDecoration(
                  hintText: locText(context, key: "search"),
                  prefixIcon: Icon(FontAwesomeIcons.search),
                //  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))
              )
          ),
    ),
    content: Container(
      height: height-searchBarHeight, width: width,
      child:
      Builder(
          builder: (BuildContext context1) {
            if(searchKeys.isNotEmpty){
              return ListView.builder(
                itemCount: searchKeys.length,
                itemBuilder: (BuildContext context2, int index) {
                  return GestureDetector(
                      onTap: () {
                        String tappedKey = searchKeys[index];
                        widget.onPicked(
                            key: tappedKey,
                            value: widget.data[tappedKey]
                        );
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 4, top: 4, bottom: 4),
                        child: InkWell(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(searchKeys[index],
                                  style: TextStyle(
                                      fontSize: 18
                                  ),
                                ),
                                Divider()
                              ]
                          ),
                        ),
                      )
                  );
                },
              );
            }else{
              return Center(child: Text(locText(context, key: "no_school_with_that_name"), style: TextStyle(fontSize: 20),));

          }
          }
      ),
    ),
    actionButtons: Row(children:[ FlatButton(child: Text(locText(context, key: "close").toUpperCase()), onPressed: (){Navigator.pop(context);},)]),
    );
    return dialog;
  }
}