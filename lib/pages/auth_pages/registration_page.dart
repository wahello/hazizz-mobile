import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/auth/social_login_bloc.dart';
import 'package:mobile/dialogs/loading_dialog.dart';
import 'package:mobile/widgets/login_widget.dart';

class LoginPage2 extends StatefulWidget {

  LoginPage2({Key key}) : super(key: key);

  @override
  _LoginPage2 createState() => _LoginPage2();
}

class _LoginPage2 extends State<LoginPage2> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder(
          bloc: LoginBlocs().googleLoginBloc,
          builder: (context, state){
            bool _isLoading = false;
            if(state is SocialLoginWaitingState){
              _isLoading = true;
            }
            return LoadingDialog(
              child: LoginWidget(),
              show: _isLoading,
            );
          },
        )
    );
  }
}
