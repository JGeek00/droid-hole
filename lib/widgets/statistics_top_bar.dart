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
    final orientation = MediaQuery.of(context).orientation;
    
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
            padding: EdgeInsets.only(
              top: 20,
              bottom: orientation == Orientation.portrait
                ? 20
                : 10,
              left: 20,
              right: 20
            ),
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
            tabs: orientation == Orientation.portrait
              ? [
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
              : [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dns_rounded),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.queriesServers)
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.http_rounded),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.domains)
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.devices_rounded),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.clients)
                    ],
                  ),
                ),
              ]
          )
        ],
      ),
    );
  }
}