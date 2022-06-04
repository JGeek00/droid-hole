import 'package:flutter/material.dart';

import 'package:droid_hole/screens/base.dart';

void main() {
  runApp(const DroidHole());
}

class DroidHole extends StatefulWidget {
  const DroidHole({Key? key}) : super(key: key);

  @override
  State<DroidHole> createState() => _DroidHoleState();
}

class _DroidHoleState extends State<DroidHole> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droid Hole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Base()
    );
  }
}
