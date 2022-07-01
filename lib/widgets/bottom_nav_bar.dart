import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/constants/app_screens.dart';

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
    String _getStringLocalization(String name) {
      switch (name) {
        case 'home':
          return AppLocalizations.of(context)!.home;

        case 'statistics':
          return AppLocalizations.of(context)!.statistics;

        case 'logs':
          return AppLocalizations.of(context)!.logs;

        case 'settings':
          return AppLocalizations.of(context)!.settings;

        default:
          return "";
      }
    }

    return BottomNavigationBar(
      currentIndex: selectedScreen,
      onTap: onChange,
      type: BottomNavigationBarType.fixed,
      items: appScreens.map((screen) => BottomNavigationBarItem(
          icon: screen.icon,
          label: _getStringLocalization(screen.name)
        )
      ).toList(),
    );
  }
}