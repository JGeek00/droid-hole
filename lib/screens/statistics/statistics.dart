import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: Text(AppLocalizations.of(context)!.statistics),
                  pinned: true,
                  floating: true,
                  centerTitle: false,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
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
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              QueriesServersTab(
                onRefresh: () async => await refreshServerStatus(context, serversProvider, appConfigProvider),
              ),
              StatisticsList(
                countLabel: AppLocalizations.of(context)!.hits,
                type: "domains",
                onRefresh: () async => await refreshServerStatus(context, serversProvider, appConfigProvider),
              ),
              StatisticsList(
                countLabel: AppLocalizations.of(context)!.requests,
                type: "clients",
                onRefresh: () async => await refreshServerStatus(context, serversProvider, appConfigProvider),
              ),
            ]
          ),
        )
      )
    );
  }
}