// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i8;

import '../main.dart' as _i1;
import '../screens/home.dart' as _i2;
import '../screens/logs.dart' as _i4;
import '../screens/servers.dart' as _i7;
import '../screens/settings.dart' as _i6;
import '../screens/statistics.dart' as _i3;

class AppRouter extends _i5.RootStackRouter {
  AppRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    Base.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.Base());
    },
    HomeRouter.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.Home());
    },
    StatisticsRouter.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.Statistics());
    },
    ListsRouter.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.Logs());
    },
    SettingsRouter.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.EmptyRouterPage());
    },
    Settings.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i6.Settings());
    },
    ServersRoute.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i7.ServersPage());
    }
  };

  @override
  List<_i5.RouteConfig> get routes => [
        _i5.RouteConfig(Base.name, path: '/', children: [
          _i5.RouteConfig(HomeRouter.name, path: 'home', parent: Base.name),
          _i5.RouteConfig(StatisticsRouter.name,
              path: 'statistics', parent: Base.name),
          _i5.RouteConfig(ListsRouter.name, path: 'lists', parent: Base.name),
          _i5.RouteConfig(SettingsRouter.name,
              path: 'settings',
              parent: Base.name,
              children: [
                _i5.RouteConfig(Settings.name,
                    path: '', parent: SettingsRouter.name),
                _i5.RouteConfig(ServersRoute.name,
                    path: 'servers', parent: SettingsRouter.name)
              ])
        ])
      ];
}

/// generated route for
/// [_i1.Base]
class Base extends _i5.PageRouteInfo<void> {
  const Base({List<_i5.PageRouteInfo>? children})
      : super(Base.name, path: '/', initialChildren: children);

  static const String name = 'Base';
}

/// generated route for
/// [_i2.Home]
class HomeRouter extends _i5.PageRouteInfo<void> {
  const HomeRouter() : super(HomeRouter.name, path: 'home');

  static const String name = 'HomeRouter';
}

/// generated route for
/// [_i3.Statistics]
class StatisticsRouter extends _i5.PageRouteInfo<void> {
  const StatisticsRouter() : super(StatisticsRouter.name, path: 'statistics');

  static const String name = 'StatisticsRouter';
}

/// generated route for
/// [_i4.Logs]
class ListsRouter extends _i5.PageRouteInfo<void> {
  const ListsRouter() : super(ListsRouter.name, path: 'lists');

  static const String name = 'ListsRouter';
}

/// generated route for
/// [_i5.EmptyRouterPage]
class SettingsRouter extends _i5.PageRouteInfo<void> {
  const SettingsRouter({List<_i5.PageRouteInfo>? children})
      : super(SettingsRouter.name, path: 'settings', initialChildren: children);

  static const String name = 'SettingsRouter';
}

/// generated route for
/// [_i6.Settings]
class Settings extends _i5.PageRouteInfo<void> {
  const Settings() : super(Settings.name, path: '');

  static const String name = 'Settings';
}

/// generated route for
/// [_i7.ServersPage]
class ServersRoute extends _i5.PageRouteInfo<void> {
  const ServersRoute() : super(ServersRoute.name, path: 'servers');

  static const String name = 'ServersRoute';
}
