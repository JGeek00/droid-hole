import 'package:droid_hole/models/app_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final List<AppScreen> screens;
  final int selectedScreen;
  final void Function(int) onChange;

  const BottomNavBar({
    Key? key,
    required this.screens,
    required this.onChange,
    required this.selectedScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedScreen,
      onTap: onChange,
      type: BottomNavigationBarType.fixed,
      items: screens.map((screen) => BottomNavigationBarItem(
          icon: screen.screenIcon,
          label: screen.screenName
        )
      ).toList(),
    );
  }
}