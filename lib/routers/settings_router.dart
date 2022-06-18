import 'package:flutter/material.dart';

import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/screens/settings.dart';

import 'package:droid_hole/models/global_keys.dart';

class SettingsRouter extends StatefulWidget {
  const SettingsRouter({Key? key}) : super(key: key);

  @override
  State<SettingsRouter> createState() => _SettingsRouterState();
}

class _SettingsRouterState extends State<SettingsRouter> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKeys.settingsRouterKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          switch (settings.name) {
            case '/':
              return const Settings();
                
            case '/servers':
              return const ServersPage();

            default:
              return const SizedBox();
          }
        }
      )
    );
  }
}