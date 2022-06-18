import 'package:flutter/material.dart';

import 'package:droid_hole/screens/statistics.dart';

import 'package:droid_hole/models/global_keys.dart';

class StatisticsRouter extends StatefulWidget {
  const StatisticsRouter({Key? key}) : super(key: key);

  @override
  State<StatisticsRouter> createState() => _StatisticsRouterState();
}

class _StatisticsRouterState extends State<StatisticsRouter> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKeys.statisticsRouterKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          switch (settings.name) {
            case '/':
              return const Statistics();
            
            default:
              return const SizedBox();
          }
        }
      )
    );
  }
}