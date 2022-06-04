import 'package:flutter/material.dart';

class AppScreen {
  final String screenName;
  final Icon screenIcon;
  final Widget screenWidget;
  
  const AppScreen({
    required this.screenIcon,
    required this.screenName,
    required this.screenWidget,
  });
}