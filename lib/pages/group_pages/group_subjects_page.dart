import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/group_bloc.dart';
import 'package:mobile/blocs/request_event.dart';
import 'package:mobile/blocs/response_states.dart';
import 'package:mobile/communication/pojos/PojoSubject.dart';
import 'package:mobile/dialogs/dialogs.dart';
import 'package:mobile/listItems/subject_item_widget.dart';

import '../../hazizz_localizations.dart';

import '../../hazizz_localizations.dart';


class GroupSubjectsPage extends StatefulWidget {
  // This widget is the root of your application.

  String getTabName(BuildContext context){
    return locText(context, key: "subjects").toUpperCase();
  }

  final GroupSubjectsBloc groupSubjectsBloc;

  GroupSubjectsPage({Key key, @required this.groupSubjectsBloc}) : super(key: key);

  @override
  _GroupSubjectsPage createState() => _GroupSubjectsPage(groupSubjectsBloc);
}

class _GroupSubjectsPage extends State<GroupSubjectsPage> with AutomaticKeepAliveClientMixin {

  GroupSubjectsBloc groupSubjectsBloc;

  _GroupSubjectsPage(this.groupSubjectsBloc);

  @override
  void initState() {
    if(groupSubjectsBloc.currentState is ResponseError) {
      groupSubjectsBloc.dispatch(FetchData());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "hero_fab_subjects",
          onPressed: () async {
            print("press");
            PojoSubject success = await showAddSubjectDialog(context, groupId: groupSubjectsBloc.groupId);
            if(success != null){
              groupSubjectsBloc.dispatch(FetchData());
            }
          },
          child: Icon(FontAwesomeIcons.plus),
        ),
        body: new RefreshIndicator(
            child: Stack(
              children: <Widget>[
                ListView(),
                BlocBuilder(
                    bloc: groupSubjectsBloc,
                    builder: (_, HState state) {
                      if (state is ResponseDataLoaded) {
                        List<PojoSubject> subjects = state.data;
                        return new ListView.builder(
                            itemCount: subjects.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SubjectItemWidget(subject: subjects[index]);

                            }
                        );
                      } else if (state is ResponseEmpty) {
                        return Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50.0),
                                  child: Text(locText(context, key: "no_subjects_yet")),
                                ),
                              )
                            ]
                        );
                      } else if (state is ResponseWaiting) {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      return Center(
                          child: Text("Uchecked State: ${state.toString()}"));
                    }
                ),
              ],
            ),
            onRefresh: () async => groupSubjectsBloc.dispatch(FetchData()) //await getData()
        )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


