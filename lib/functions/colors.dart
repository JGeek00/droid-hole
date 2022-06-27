import 'dart:math';

import 'package:flutter/material.dart';

Color generateRandomColor() {
  Random rnd = Random();
  return Color.fromRGBO(
    (0 + rnd.nextInt(255 - 0)), 
    (0 + rnd.nextInt(255 - 0)), 
    (0 + rnd.nextInt(255 - 0)), 
    1
  );
}