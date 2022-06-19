import 'package:flutter/material.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/logs.dart';
import 'package:droid_hole/screens/settings.dart';
import 'package:droid_hole/screens/statistics.dart';

import 'package:droid_hole/models/app_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedScreen;
  final Function(int) onChange;

  const BottomNavBar({
    Key? key,
    required this.selectedScreen,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<AppScreen> appScreens = [
      const AppScreen(
        screenIcon: Icon(Icons.home), 
        screenName: "Home", 
        screenWidget: Home(),
      ),
      const AppScreen(
        screenIcon: Icon(Icons.analytics_rounded), 
        screenName: "Statistics", 
        screenWidget: Statistics(),
      ),
      const AppScreen(
        screenIcon: Icon(Icons.list_alt_rounded), 
        screenName: "Logs", 
        screenWidget: Logs(),
      ),
      const AppScreen(
        screenIcon: Icon(Icons.settings), 
        screenName: "Settings", 
        screenWidget: Settings(),
      ),
    ];

    return BottomNavigationBar(
      currentIndex: selectedScreen,
      onTap: onChange,
      type: BottomNavigationBarType.fixed,
      items: appScreens.map((screen) => BottomNavigationBarItem(
          icon: screen.screenIcon,
          label: screen.screenName
        )
      ).toList(),
    );
  }
}