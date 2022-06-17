import 'package:flutter/material.dart';

import 'package:droid_hole/screens/lists.dart';

import 'package:droid_hole/models/global_keys.dart';

class ListsRouter extends StatefulWidget {
  const ListsRouter({Key? key}) : super(key: key);

  @override
  State<ListsRouter> createState() => _ListsRouterState();
}

class _ListsRouterState extends State<ListsRouter> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKeys.listsRouterKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          switch (settings.name) {
            case '/':
              return const Lists();
                
            default:
              return const SizedBox();
          }
        }
      )
    );
  }
}