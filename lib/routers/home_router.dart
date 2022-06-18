import 'package:flutter/material.dart';

import 'package:droid_hole/screens/home.dart';

import 'package:droid_hole/models/global_keys.dart';

class HomeRouter extends StatefulWidget {
  const HomeRouter({Key? key}) : super(key: key);

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKeys.homeRouterKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          switch (settings.name) {
            case '/':
              return const Home();

            default:
              return const SizedBox();
          }
        }
      )
    );
  }
}