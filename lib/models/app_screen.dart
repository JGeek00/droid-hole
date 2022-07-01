import 'package:flutter/material.dart';
class AppScreen {
  final String name;
  final Icon icon;
  final Widget widget;
  
  const AppScreen({
    required this.icon,
    required this.name,
    required this.widget,
  });
}