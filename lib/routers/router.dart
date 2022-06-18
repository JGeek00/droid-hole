import 'package:auto_route/auto_route.dart';

import 'package:droid_hole/main.dart';
import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/lists.dart';
import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/screens/settings.dart';
import 'package:droid_hole/screens/statistics.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(
      path: '/',
      page: Base,
      children: [
        AutoRoute(
          path: 'home',
          name: 'HomeRouter',
          page: Home,
        ),
        AutoRoute(
          path: 'statistics',
          name: 'StatisticsRouter',
          page: Statistics,
        ),
        AutoRoute(
          path: 'lists',
          name: 'ListsRouter',
          page: Lists,
        ),
        AutoRoute(
          path: 'settings',
          name: 'SettingsRouter',
          page: EmptyRouterPage,
          children: [
            AutoRoute(
              path: '',
              page: Settings
            ),
            AutoRoute(
              path: 'servers',
              page: ServersPage
            )
          ]
        ),
      ]
    )
  ]
)
class $AppRouter {}