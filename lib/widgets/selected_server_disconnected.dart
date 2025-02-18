import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/functions/refresh_server_status.dart';

class SelectedServerDisconnected extends StatelessWidget {
  const SelectedServerDisconnected({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: height-180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectedDisconnected,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 26
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () => refreshServerStatus(context),
                  icon: const Icon(Icons.refresh), 
                  label: Text(AppLocalizations.of(context)!.tryReconnect)
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}