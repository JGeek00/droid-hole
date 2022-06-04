import 'package:flutter/material.dart';

class Fab {
  final Icon icon;
  final Color color;
  final void Function() onTap;

  const Fab({
    required this.icon,
    required this.color,
    required this.onTap
  });
}