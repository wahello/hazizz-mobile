import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/widgets/ad_widget.dart';
import 'package:mobile/widgets/hazizz_back_button.dart';

import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mobile/managers/preference_services.dart';


class SettingsPage extends StatefulWidget {

  String getTitle(BuildContext context){
    return locText(context, key: "settings");
  }

  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>  {

  String currentLanguageCode ;//= Locale("en", "EN");

  List<DropdownMenuItem> startPageItems = List();
  static List<Locale> supportedLocales = getSupportedLocales();
  List<DropdownMenuItem> supportedLocaleItems = List();


  String currentLocale = supportedLocales[0].languageCode;

  int currentStartPageItemIndex = 0;

  _SettingsPage();


 // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
   // widget.myGroupsBloc.add(FetchData());

    getPreferredLocale().then((preferredLocale){
      setState(() {
        currentLanguageCode = preferredLocale.languageCode;
      });
    });

    PreferenceService.getStartPageIndex().then(
      (int value){
        setState(() {
          currentStartPageItemIndex = value;
        });
      }
    );

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    if(startPageItems.isEmpty) {

      List<StartPageItem> startPages = PreferenceService.getStartPages(context);
      for(StartPageItem startPage in startPages) {
        startPageItems.add(DropdownMenuItem(
          value: startPage.index,
          child: Text(startPage.name,
            textAlign: TextAlign.end,
          ),
        ));
      }
    }
    if(supportedLocaleItems.isEmpty){
      supportedLocales = getSupportedLocales();

      HazizzLogger.printLog("supported locales: ${supportedLocales.toString()}");

      for(Locale locale in supportedLocales) {

        supportedLocaleItems.add(DropdownMenuItem(
          value: locale.languageCode,
          child: Text(locale.languageCode,
            textAlign: TextAlign.end,
          ),
        ));
      }

    }

    HazizzLogger.printLog("log: $supportedLocaleItems");


    return Scaffold(
        appBar: AppBar(
          leading: HazizzBackButton(),
          title: Text(widget.getTitle(context))

        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40),
          child: Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/about");
                  },
                  title: Text(locText(context, key: "about")),
                  leading: Icon(FontAwesomeIcons.infoCircle),
                ),
              ),
              Divider(),

              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/settings/preferences");
                  },
                  title: Text(locText(context, key: "preferences")),
                  leading: Icon(FontAwesomeIcons.asterisk),
                ),
              ),
              Divider(),
              ListTile(
                onTap: (){
                  Navigator.pushNamed(context, "/settings/google_drive_settings");
                },
                title: Text(locText(context, key: "google_drive_settings")),
                leading: Icon(FontAwesomeIcons.googleDrive),
              ),
              /*
              Divider(),
              ListTile(
                onTap: () async {
                  Navigator.pushNamed(context, "/settings/kreta");
                },
                leading: Icon(FontAwesomeIcons.landmark),
                title: Text(locText(context, key: "kreta_settings")),
                // trailing: Text("time")
              ),
              */
              /*
              Divider(),
              ListTile(
                onTap: () async {
                  Navigator.pushNamed(context, "/settings/notification");
                },
                leading: Icon(FontAwesomeIcons.solidBell),
                title: Text(locText(context, key: "notification_settings")),
               // trailing: Text("time")
              ),
              */
              Divider(),

              /*
              ListTile(
                title: Text(locText(context, key: "language")),
                leading: Icon(FontAwesomeIcons.language),
                trailing: DropdownButton(

                  items: supportedLocaleItems,
                  onChanged: (dynamic selectedLocale) async {
                  //  StartPageService.setStartPageIndex(newStartPageIndex);
                    HazizzLogger.printLog(selectedLocale);
                    setState(() {
                      currentLocale = selectedLocale;


                      this.setState(() {
                        var data = EasyLocalizationProvider.of(context).data;
                        data.changeLocale(Locale(selectedLocale.toLowerCase()));
                        HazizzLogger.printLog(Localizations.localeOf(context).languageCode);
                      });


                    });
                  },
                  value: currentLocale,
                ),
              ),
              Divider(),
              */

              ListTile(
                onTap: () async {
                  Navigator.pushNamed(context, "/settings/profile_editor");
                },
                leading: Icon(FontAwesomeIcons.solidUser),
                title: Text(locText(context, key: "profile_editor")),
              ),

              Divider(),
              ListTile(
                onTap: () async {
                  Navigator.pushNamed(context, "/settings/developer");
                },
                leading: Icon(FontAwesomeIcons.wrench),
                title: Text(locText(context, key: "developer_settings")),
              ),
              Divider(),
              Builder(
                builder: (context){
                  return ListTile(
                    leading: Icon(FontAwesomeIcons.language),
                    title: Text(locText(context, key: "language")),
                    trailing: DropdownButton(
                      value: currentLanguageCode,
                      onChanged: (value){
                        setState(() {
                          currentLanguageCode = value;
                          HazizzLocalizations.of(context).load(Locale(currentLanguageCode));
                          setPreferredLocale(Locale(currentLanguageCode));


                        });
                      },
                      items: supportedLocaleItems
                    ),
                  );

                },
              ),
              Divider(),
              showAd(context),
            ],
          ),
        )
      );
  }
}
