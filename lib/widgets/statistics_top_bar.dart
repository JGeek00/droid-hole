import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final topBarHeight = MediaQuery.of(context).viewPadding.top;
    
    return Container(
      margin: EdgeInsets.only(top: topBarHeight),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          )
        )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.statistics,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                )
              ],
            ),
          ),
          if (
            serversProvider.selectedServer != null &&
            serversProvider.isServerConnected == true  
          ) TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.dns_rounded),
                text: AppLocalizations.of(context)!.queriesServers,
              ),
              Tab(
                icon: const Icon(Icons.http_rounded),
                text: AppLocalizations.of(context)!.domains,
              ),
              Tab(
                icon: const Icon(Icons.devices_rounded),
                text: AppLocalizations.of(context)!.clients,
              ),
            ]
          )
        ],
      ),
    );
  }
}