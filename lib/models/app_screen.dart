import 'package:flutter/material.dart';

import 'fab.dart';

class AppScreen {
  final String screenName;
  final Icon screenIcon;
  final Widget screenWidget;
  final Fab? screenFab;
  
  const AppScreen({
    required this.screenIcon,
    required this.screenName,
    required this.screenWidget,
    this.screenFab,
  });
}