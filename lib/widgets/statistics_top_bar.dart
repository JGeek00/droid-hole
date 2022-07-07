import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20-(20*(1-textScaleFactor).abs()),
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
                    height: 72,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dns_rounded,
                          size: 25-(25*(1-textScaleFactor).abs()),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: width/3,
                          child: Text(
                            AppLocalizations.of(context)!.queriesServers,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14-(14*(1-textScaleFactor).abs())
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Tab(
                    height: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.http_rounded,
                          size: 25-(25*(1-textScaleFactor).abs()),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: width/3,
                          child: Text(
                            AppLocalizations.of(context)!.domains,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14-(14*(1-textScaleFactor).abs())
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Tab(
                    height: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_rounded,
                          size: 25-(25*(1-textScaleFactor).abs()),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: width/3,
                          child: Text(
                            AppLocalizations.of(context)!.clients,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14-(14*(1-textScaleFactor).abs())
                            ),
                          ),
                        )
                      ],
                    ),
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