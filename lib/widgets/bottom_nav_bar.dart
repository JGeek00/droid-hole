import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      AppScreen(
        screenIcon: const Icon(Icons.home), 
        screenName: AppLocalizations.of(context)!.home, 
        screenWidget: const Home(),
      ),
      AppScreen(
        screenIcon: const Icon(Icons.analytics_rounded), 
        screenName: AppLocalizations.of(context)!.statistics, 
        screenWidget: const Statistics(),
      ),
      AppScreen(
        screenIcon: const Icon(Icons.list_alt_rounded), 
        screenName: AppLocalizations.of(context)!.logs, 
        screenWidget: const Logs(),
      ),
      AppScreen(
        screenIcon: const Icon(Icons.settings), 
        screenName: AppLocalizations.of(context)!.settings, 
        screenWidget: const Settings(),
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