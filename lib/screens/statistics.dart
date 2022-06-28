import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';
import 'package:droid_hole/widgets/statistics_list.dart';
import 'package:droid_hole/widgets/statistics_queries_servers_tab.dart';
import 'package:droid_hole/widgets/statistics_top_bar.dart';

import 'package:droid_hole/providers/servers_provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    Widget _generateBody() {
      switch (serversProvider.getStatusLoading) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 50),
                Text(
                  "Loading stats...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return TabBarView(
            children: [
              const QueriesServersTab(),
              StatisticsList(
                data1: serversProvider.getRealtimeStatus!.topQueries.isNotEmpty == true 
                  ? {
                      "data": serversProvider.getRealtimeStatus!.topQueries,
                      "label": "Top permitted domains"
                    }
                  : null,
                data2: serversProvider.getRealtimeStatus!.topAds.isNotEmpty == true 
                  ? {
                      "data": serversProvider.getRealtimeStatus!.topAds,
                      "label": "Top blocked domains"
                    }
                  : null,
                countLabel: "Hits:",
              ),
              StatisticsList(
                data1: serversProvider.getRealtimeStatus!.topSources.isNotEmpty == true 
                  ? {
                      "data": serversProvider.getRealtimeStatus!.topSources,
                      "label": "Top clients (total)"
                    }
                  : null,
                data2: serversProvider.getRealtimeStatus!.topSourcesBlocked.isNotEmpty == true 
                  ? {
                      "data": serversProvider.getRealtimeStatus!.topSourcesBlocked,
                      "label": "Top clients (blocked only)"
                    }
                  : null,
                countLabel: "Requests:",
              ),
            ]
          );

        case 2:
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 50),
                Text(
                  "Stats could not be loaded",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
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
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(
            double.maxFinite, 
            serversProvider.selectedServer != null && serversProvider.isServerConnected == true 
              ? 138
              : 64
          ),
          child: const StatisticsTopBar()
        ),
        body: serversProvider.selectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? RefreshIndicator(
              onRefresh: () async {
                await refreshServerStatus(context, serversProvider);
              },
              child: _generateBody()
            )
          : const Center(
              child: SelectedServerDisconnected()
            )
        : const NoServerSelected()
      ),
    );
  }
}