import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/models/app_screen.dart';

class CustomNavigationRail extends StatelessWidget {
  final List<AppScreen> screens;
  final int selectedScreen;
  final Function(int) onChange;

  const CustomNavigationRail({
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

    return NavigationRail(
      selectedIndex: selectedScreen,
      onDestinationSelected: onChange,
      destinations: screens.map((screen) => NavigationRailDestination(
        icon: screen.icon,
        label: Text(getStringLocalization(screen.name))
      )).toList(),
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      groupAlignment: 0,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
    );
  }
}