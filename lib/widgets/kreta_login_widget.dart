
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/item_list/item_list_picker_bloc.dart';
import 'package:mobile/blocs/kreta/kreta_login_blocs.dart';
import 'package:mobile/communication/errorcode_collection.dart';
import 'package:mobile/communication/pojos/PojoSession.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/dialogs/dialogs.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/dialogs/loading_dialog.dart';
import 'package:mobile/theme/hazizz_theme.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:xs_progress_hud/xs_progress_hud.dart';

import 'package:mobile/custom/hazizz_localizations.dart';

class KretaLoginWidget extends StatefulWidget {

  Function onSuccess;
  PojoSession sessionToAuth;

  KretaLoginWidget({Key key, @required this.onSuccess}) : super(key: key);

  KretaLoginWidget.auth({Key key, @required this.sessionToAuth,}) : super(key: key);

  @override
  _KretaLoginWidget createState() => _KretaLoginWidget();
}

class _KretaLoginWidget extends State<KretaLoginWidget> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  KretaLoginPageBlocs kretaLoginBlocs;


  XsProgressHud hud = XsProgressHud();

  ProgressDialog pr;

  bool passwordVisible = true;

  final TextEditingController _usernameTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController =TextEditingController();

  @override
  void initState() {
    pr = new ProgressDialog(context,ProgressDialogType.Normal);
    if(widget.sessionToAuth != null){
      kretaLoginBlocs = KretaLoginPageBlocs.auth(session: widget.sessionToAuth);
    }else{
      kretaLoginBlocs = new KretaLoginPageBlocs();

    }
    super.initState();
  }

  @override
  void dispose() {
    kretaLoginBlocs.dispose();
    _usernameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  Future<void> showCustomHud(BuildContext context) async {
    pr.show();
   // hud.progressColor = Colors.red;
   // Navigator.push(context, hud);
  }

  Future<void> stopCustomHud() async {
    pr.hide();
   // hud.navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    pr.setMessage(locText(context, key: "loading"));

    if(widget.onSuccess == null){
      widget.onSuccess = () => Navigator.pop(context);
    }
    var usernameWidget = TextField(


      enabled: widget.sessionToAuth == null,
      style: TextStyle(fontSize: 18),

      controller: kretaLoginBlocs.kretaLoginBloc.usernameController,
      textInputAction: TextInputAction.next,
      decoration:
      InputDecoration(
        labelText: locText(context, key: "kreta_username"), errorStyle: TextStyle(color: Colors.black),

        filled: true,
        fillColor: Colors.grey.withAlpha(120)

        // helperText: "Oktatási azonositó",
      ),
    );

    var passwordWidget =  Stack(
      children: <Widget>[
        Container(
          //  height: 75,
          child: TextField(
            style: TextStyle(fontSize: 18),
            maxLines: 1,

            controller: kretaLoginBlocs.kretaLoginBloc.passwordController,
            textInputAction: TextInputAction.next,
            obscureText: passwordVisible,
            decoration:
            InputDecoration(labelText: locText(context, key: "kreta_password"),// helperText: "Oktatási azonositó",
              alignLabelWithHint: true,
              labelStyle: TextStyle(

              ),
              filled: true,
              fillColor: Colors.grey.withAlpha(120),

            ),
          ),
        ),
        Positioned(
          right: 6, top: 8,
          child: IconButton(
            //  padding: const EdgeInsets.only(top:  20),
            icon: Icon(
              // Based on passwordVisible state choose the icon

              passwordVisible
                  ? FontAwesomeIcons.solidEyeSlash
                  : FontAwesomeIcons.solidEye,
            ),
            onPressed: () {
              // Update the state i.e. Ftoogle the state of passwordVisible variable
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
          ),
        )
      ],
    );



    var schoolPickerWidget = BlocBuilder(
      bloc: kretaLoginBlocs.schoolBloc,
      builder: (BuildContext context, ItemListState state) {
        return GestureDetector(
          child: FormField(

            enabled: widget.sessionToAuth == null,

            builder: (FormFieldState formState) {
              return InputDecorator(
                  baseStyle: TextStyle(fontSize: 22, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withAlpha(120),
                    labelText: locText(context, key: "school"),
                  ),

                  child: Builder(
                    builder: (BuildContext context){//, ItemListState state) {
                      if (state is ItemListLoaded) {
                        return Container();
                      }
                      if(state is ItemListPickedState){
                        return Text('${state.item.name}',
                          style: TextStyle(fontSize: 16),

                        );
                      }
                      return Text(locText(context, key: "loading"));
                    },
                  )
              );
            },
          ), //groupFormField,
          onTap: () {

            if (widget.sessionToAuth == null) {
              if(kretaLoginBlocs.schoolBloc.currentState is ItemListLoaded
                  || kretaLoginBlocs.schoolBloc.currentState is ItemListPickedState
              ){
                showSchoolsDialog(context, data: kretaLoginBlocs.schoolBloc.data,
                    onPicked: ({String key, String value}){
                      HazizzLogger.printLog("school picked: key: $key, value: $value");
                      kretaLoginBlocs.schoolBloc.dispatch(PickedEvent(item: SchoolItem(key, value)));
                    }
                );
              }
            }
          },
        );
      }
    );

    return BlocBuilder(
      bloc: kretaLoginBlocs.kretaLoginBloc,
      builder: (context, state){
        String responseInfo = "";
        bool isLoading = false;


        if(state is KretaLoginWaiting) {
          //  isLoading = true;
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              showCustomHud(context)
          );
        }else if(state is KretaLoginSuccessState){
          WidgetsBinding.instance.addPostFrameCallback((_){
              stopCustomHud();
              widget.onSuccess();
            }
          );

        }else{
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              stopCustomHud()
          );
          if(state is KretaLoginFailure) {
            if(state.error.errorCode == ErrorCodes.THERA_AUTHENTICATION_ERROR.code){
              responseInfo = locText(context, key: "incorrect_data");
            }else if(state.error.errorCode == ErrorCodes.GENERAL_THERA_ERROR.code){
              responseInfo = locText(context, key: "kreta_server_unavailable");
            }else{
              responseInfo = locText(context, key: "try_again_later");
            }


          }else if(state is KretaLoginSomethingWentWrong){
            responseInfo = locText(context, key: "try_again_later");
            //stopCustomHud();
          }else{
            // stopCustomHud();
          }
        }




        return LoadingDialog(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                /*
              Image.asset(
                'assets/images/Logo.png',
              ),
              */

                Padding(
                  padding: EdgeInsets.only(left:16, right:16, bottom: 0),
                  child: usernameWidget,
                ),
                Padding(
                  padding: EdgeInsets.only(left:16, right:16, top: 4),
                  child: Row(
                    children: <Widget>[
                      Flexible(child: Text("Oktatási azonositód, 11 karakteres", style: TextStyle(color: Colors.grey)))
                    ],
                  ),
                ),


                Padding(
                  padding: EdgeInsets.only(left:16, right:16, bottom: 0),
                  child: passwordWidget,
                ),

                Padding(
                  padding: EdgeInsets.only(left:16, right:16, top: 4),
                  child: Row(
                    children: <Widget>[
                      Flexible(child: Text("Ha nem állítotad át akkor a születési dátumod. pl: 2002-01-17", style: TextStyle(color: Colors.grey),))
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left:16, right:16, top:4, bottom: 4),
                  child: schoolPickerWidget,
                ),

                Text(responseInfo, style: TextStyle(color: HazizzTheme.red),),

                BlocListener(
                  bloc: kretaLoginBlocs.kretaLoginBloc,
                  listener: (context, state) {
                    if (state is KretaLoginSuccessState) {
                      //  Navigator.of(context).pushNamed('/details');

                      //  Navigator.popAndPushNamed(context, "/");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RaisedButton(
                        child: Text(locText(context, key: "login").toUpperCase()),
                        onPressed: () async {
                          if(kretaLoginBlocs.schoolBloc.currentState is ItemListPickedState || true) {
                            FocusScope.of(context).requestFocus(new FocusNode());

                            kretaLoginBlocs.kretaLoginBloc.dispatch(
                                KretaLoginButtonPressed(
                                    password: _passwordTextEditingController.text,
                                    username: _usernameTextEditingController.text,
                                    schoolUrl: kretaLoginBlocs.schoolBloc.pickedItem?.url
                                )
                            );
                          }
                        }
                    ),
                  ),
                )
              ],
            ),
          ),
          show: isLoading,
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
