import 'package:flutter/material.dart';
import 'package:mobile/pages/kreta_session_selector_page.dart';
import 'package:mobile/pages/notification_settings_page.dart';
import 'package:mobile/widgets/kreta_session_selector_widget.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/group_pages/group_tab_hoster_page.dart';
import 'package:mobile/pages/intro_page.dart';
import 'package:mobile/pages/kreta_login_page.dart';
import 'package:mobile/pages/main_pages/main_tab_hoster_page.dart';
import 'package:mobile/pages/my_groups_page.dart';
import 'package:mobile/pages/profile_editor_page.dart';
import 'package:mobile/pages/registration_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/task_maker_page.dart';
import 'package:mobile/pages/tomorrow_tasks_page.dart';

import 'main.dart';

class RouteGenerator{
  static Route<dynamic> _errorRoute(String errorLog) {
    print(errorLog);
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text(errorLog),
        ),
      );
    });
  }

  static Route generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case 'login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case 'registration':
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      case 'intro':
        return MaterialPageRoute(builder: (_) => IntroPage());
      case '/':
        return MaterialPageRoute(builder: (_) => MainTabHosterPage());
      case '/tasksTomorrow':
        return MaterialPageRoute(builder: (_) => TasksTomorrowPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case '/settings/notification':
        return MaterialPageRoute(builder: (_) => NotificationSettingsPage());
      case '/settings/profile_editor':
        return MaterialPageRoute(builder: (_) => ProfileEditorPage());
      case '/groups':
        return MaterialPageRoute(builder: (_) => MyGroupsPage());
      case '/group/groupId': //assert(args != null);
        return MaterialPageRoute(builder: (_) => GroupTabHosterPage(group: args));
      case '/createTask':
        return MaterialPageRoute(builder: (_) => TaskMakerPage.createMode(groupId: args));
      case '/editTask': assert(args != null);
        return MaterialPageRoute(builder: (_) => TaskMakerPage.editMode(taskToEdit: args,));
      case '/kreta/login': assert(args != null);
        return MaterialPageRoute(builder: (_) => KretaLoginPage(onSuccess: args));
      case '/kreta/login/auth': assert(args != null);
        return MaterialPageRoute(builder: (_) => KretaLoginPage.auth(sessionToAuth: args));
      case '/kreta/accountSelector':
        return MaterialPageRoute(builder: (_) => SessionSelectorPage());
      default:
        String errorLog = "log: route: ${settings.name}, args: ${settings.arguments}";
        return _errorRoute(errorLog);
    }
  }
}

