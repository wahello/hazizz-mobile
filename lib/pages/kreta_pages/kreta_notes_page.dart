import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/kreta/kreta_notes_bloc.dart';
import 'package:mobile/blocs/other/request_event.dart';
import 'package:mobile/blocs/other/response_states.dart';
import 'package:mobile/communication/pojos/PojoKretaNote.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/widgets/hazizz_back_button.dart';

import 'package:mobile/widgets/note_widget.dart';

class KretaNotesPage extends StatefulWidget {

  @override
  _KretaNotesPage createState() => _KretaNotesPage();
}

class _KretaNotesPage extends State<KretaNotesPage> with AutomaticKeepAliveClientMixin {

  KretaNotesBloc notesBloc = KretaNotesBloc();

  @override
  void initState() {
    notesBloc.dispatch(FetchData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          leading: HazizzBackButton(),
          title: Text(locText(context, key: "kreta_notes")),
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            notesBloc.dispatch(FetchData());
          },
          child: Stack(
            children: <Widget>[

              ListView(),
              BlocBuilder(
                bloc: notesBloc,
                builder: (context, state){
                  if(state is ResponseDataLoaded){
                    List<PojoKretaNote> notes = state.data;
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index){
                        return NoteItemWidget(note: notes[index]);

                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              )
            ],
          ),
        )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


