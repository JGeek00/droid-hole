import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/models/app_screen.dart';

class BottomNavBar extends StatelessWidget {
  final List<AppScreen> screens;
  final int selectedScreen;
  final Function(int) onChange;

  const BottomNavBar({
    super.key,
    required this.screens,
    required this.selectedScreen,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    String getStringLocalization(String name) {
      switch (name) {
        case 'home':
          return AppLocalizations.of(context)!.home;

        case 'statistics':
          return AppLocalizations.of(context)!.statistics;

        case 'logs':
          return AppLocalizations.of(context)!.logs;

        case 'domains':
          return AppLocalizations.of(context)!.domains;

        case 'settings':
          return AppLocalizations.of(context)!.settings;

        case 'connect':
          return AppLocalizations.of(context)!.connect;

        default:
          return "";
      }
    }

    return NavigationBar(
      selectedIndex: selectedScreen,
      onDestinationSelected: onChange,
      destinations: screens.map((screen) => NavigationDestination(
          icon: screen.icon,
          label: getStringLocalization(screen.name)
        )
      ).toList(),
    );
  }
}