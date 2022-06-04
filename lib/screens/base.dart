import 'package:droid_hole/functions/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/screens/settings.dart';

import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/models/app_screen.dart';
import 'package:droid_hole/models/fab.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int selectedScreen = 0;

  void _changeScreen(screeenIndex) {
    setState(() {
      selectedScreen = screeenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<AppScreen> appScreens = [
      AppScreen(
        screenIcon: const Icon(Icons.home), 
        screenName: "Home", 
        screenWidget: const Home(),
        screenFab: Fab(
          icon: const Icon(Icons.verified_user_rounded), 
          color: Colors.green, 
          onTap: () => openEnableDisableBottomSheet(context)
        )
      ),
      const AppScreen(
        screenIcon: Icon(Icons.storage_rounded), 
        screenName: "Servers", 
        screenWidget: Servers()
      ),
      const AppScreen(
        screenIcon: Icon(Icons.settings), 
        screenName: "Settings", 
        screenWidget: Settings()
      ),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        screens: appScreens,
        selectedScreen: selectedScreen,
        onChange: _changeScreen,
      ),
      body: SafeArea(child: appScreens[selectedScreen].screenWidget),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: appScreens[selectedScreen].screenFab != null 
        ? FloatingActionButton(
            onPressed: appScreens[selectedScreen].screenFab?.onTap,
            backgroundColor: appScreens[selectedScreen].screenFab?.color,
            child: appScreens[selectedScreen].screenFab?.icon,
          )
        : null,
    );
  }
}