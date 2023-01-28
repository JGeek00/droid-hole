import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';
import 'package:droid_hole/screens/statistics/statistics_list.dart';
import 'package:droid_hole/screens/statistics/statistics_queries_servers_tab.dart';

import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final orientation = MediaQuery.of(context).orientation;

    Widget _generateBody() {
      switch (serversProvider.getStatusLoading) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.loadingStats,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return NestedScrollView(
            headerSliverBuilder: ((context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      title: Text(AppLocalizations.of(context)!.statistics),
                      centerTitle: true,
                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                      bottom: serversProvider.selectedServer != null && serversProvider.isServerConnected == true  
                        ? TabBar(
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
                      : null
                    ),
                  ),
                )
              ];
            }),
            body: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromRGBO(220, 220, 220, 1)
                      : const Color.fromRGBO(50, 50, 50, 1)
                  )
                )
              ),
              child: TabBarView(
                children: [
                  const QueriesServersTab(),
                  StatisticsList(
                    data1: {
                      "data": serversProvider.getRealtimeStatus!.topQueries.isNotEmpty == true 
                        ? serversProvider.getRealtimeStatus!.topQueries
                        : null,
                      "label": AppLocalizations.of(context)!.topPermittedDomains
                    },
                    data2: {
                      "data": serversProvider.getRealtimeStatus!.topAds.isNotEmpty == true 
                        ? serversProvider.getRealtimeStatus!.topAds
                        : null,
                      "label": AppLocalizations.of(context)!.topBlockedDomains
                    },
                    countLabel: AppLocalizations.of(context)!.hits,
                    type: "domains",
                  ),
                  StatisticsList(
                    data1: {
                      "data":  serversProvider.getRealtimeStatus!.topSources.isNotEmpty == true 
                        ? serversProvider.getRealtimeStatus!.topSources
                        : null,
                      "label": AppLocalizations.of(context)!.topClients
                    },
                    data2: {
                      "data": serversProvider.getRealtimeStatus!.topSourcesBlocked.isNotEmpty == true 
                        ? serversProvider.getRealtimeStatus!.topSourcesBlocked
                        : null,
                      "label": AppLocalizations.of(context)!.topClientsBlocked
                    },
                    countLabel: AppLocalizations.of(context)!.requests,
                    type: "clients",
                  ),
                ]
              ),
            ),
          );

        case 2:
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.statsNotLoaded,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        default:
          return const SizedBox();
      }
    }

    return DefaultTabController(
      length: 3,
      child: serversProvider.selectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? RefreshIndicator(
              onRefresh: () async {
                await refreshServerStatus(context, serversProvider, appConfigProvider);
              },
              child: Scaffold(
                body: _generateBody()
              )
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.statistics),
                centerTitle: true,
              ),
              body: const Center(
                child: SelectedServerDisconnected()
              ),
            )
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.statistics),
              centerTitle: true,
            ),
            body: const NoServerSelected()
          )
    );
  }
}