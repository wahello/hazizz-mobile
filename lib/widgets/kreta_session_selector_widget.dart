import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/other/request_event.dart';
import 'package:mobile/blocs/other/response_states.dart';
import 'package:mobile/blocs/kreta/selected_session_bloc.dart';
import 'package:mobile/blocs/kreta/sessions_bloc.dart';
import 'package:mobile/communication/pojos/PojoSession.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/listItems/session_item_widget.dart';
import 'package:mobile/widgets/scroll_space_widget.dart';

class SessionSelectorWidget extends StatefulWidget {

  bool fromDedicatedPage = false;

  SessionSelectorWidget({Key key}) : super(key: key);

  SessionSelectorWidget.fromDedicatedPage({Key key}) : super(key: key){
    fromDedicatedPage = true;
  }

  @override
  _SessionSelectorWidget createState() => _SessionSelectorWidget();
}

class _SessionSelectorWidget extends State<SessionSelectorWidget> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    initalizeSelectedSession();
    SessionsBloc().dispatch(FetchData());
    super.initState();
  }

  List<PojoSession> sessions = List();
  SessionItemWidget selectedSessionWidget;
   void initalizeSelectedSession(){
    SelectedSessionState currentState = SelectedSessionBloc().currentState;

    HazizzLogger.printLog("initalize SelectedSessionState: ${currentState.toString()}");

    if(currentState is SelectedSessionEmptyState){

    }else if(currentState is SelectedSessionInactiveState){

    }else if(currentState is SelectedSessionFineState){

      PojoSession selectedSession = currentState.session;
      sessions.remove(selectedSession);
      selectedSessionWidget = SessionItemWidget(session: selectedSession,);
    }
  }

  Widget showSessionWidgets(List<PojoSession> s){
    List<PojoSession> sessions1 = s;

    if(sessions1.isEmpty){
      return Center(child: Text(locText(context, key: "no_kreta_account_added_yet")));
    }
    return BlocBuilder(
      bloc: SelectedSessionBloc(),
      builder: (context2, state2){
        sessions.clear();
        sessions.addAll(sessions1);
        HazizzLogger.printLog("session change: $state2: ${sessions1}");
        if(sessions.isNotEmpty){
          return new ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (BuildContext context, int index) {
                if(index >= sessions.length-1){
                  return addScrollSpace(SessionItemWidget(session: sessions[index],));
                }
                return SessionItemWidget(session: sessions[index],);
              }
          );
        }
        return Text(locText(context, key: "should_add_kreta_account"));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SessionsBloc().sessions.length <= 10 ?
        FloatingActionButton(
          heroTag: null,
          child: Icon(FontAwesomeIcons.userPlus),
          onPressed: () async {
            var doRefresh = await Navigator.pushNamed(context, "/kreta/login", /* arguments: (){
            }*/);
            if(doRefresh != null && doRefresh is bool && doRefresh){
              SessionsBloc().dispatch(FetchData());
            }
          },
        ) : Container(),

      body: RefreshIndicator(
        child: Stack(
          children: <Widget>[
            ListView(),
            Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: BlocBuilder(
                          bloc: SessionsBloc(),
                          builder: (_, HState state) {
                            if (state is ResponseDataLoaded) {
                              return showSessionWidgets(state.data);

                            }else if(state is ResponseDataLoadedFromCache){
                              return showSessionWidgets(state.data);
                            }
                            else if (state is ResponseWaiting) {
                              return Center(child: CircularProgressIndicator(),);
                            }
                            return Center(
                                child: Text(locText(context, key: "info_something_went_wrong")));
                          }
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            )
          ],
        ),
        onRefresh: () async => SessionsBloc().dispatch(FetchData()) //await getData()
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}


