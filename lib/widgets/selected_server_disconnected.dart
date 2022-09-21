import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class SelectedServerDisconnected extends StatelessWidget {
  const SelectedServerDisconnected({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 26
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () => refreshServerStatus(context, serversProvider),
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