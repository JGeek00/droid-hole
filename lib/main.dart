import 'package:flutter/material.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/settings.dart';

import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/models/app_screen.dart';

void main() {
  runApp(const DroidHole());
}

class DroidHole extends StatefulWidget {
  const DroidHole({Key? key}) : super(key: key);

  @override
  State<DroidHole> createState() => _DroidHoleState();
}

class _DroidHoleState extends State<DroidHole> {
  int selectedScreen = 0;

  void _changeScreen(screeenIndex) {
    setState(() {
      selectedScreen = screeenIndex;
    });
  }

  List<AppScreen> appScreens = [
    const AppScreen(
      screenIcon: Icon(Icons.home), 
      screenName: "Home", 
      screenWidget: Home()
    ),
    const AppScreen(
      screenIcon: Icon(Icons.settings), 
      screenName: "Settings", 
      screenWidget: Settings()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droid Hole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(
          screens: appScreens,
          selectedScreen: selectedScreen,
          onChange: _changeScreen,
        ),
        body: SafeArea(child: appScreens[selectedScreen].screenWidget),
      ),
    );
  }
}
