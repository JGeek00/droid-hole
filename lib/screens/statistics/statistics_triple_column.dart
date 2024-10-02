import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/statistics/statistics_list.dart';
import 'package:droid_hole/screens/statistics/statistics_queries_servers_tab.dart';

import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/status_provider.dart';

class StatisticsTripleColumn extends StatelessWidget {
  const StatisticsTripleColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);

    Widget body() {
      switch (statusProvider.getStatusLoading) {
        case LoadStatus.loading:
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

        case LoadStatus.loaded:
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              AppLocalizations.of(context)!.queriesServers,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          children: const [
                            QueriesServersTabContent(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.domains,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            StatisticsListContent(
                              type: "domains", 
                              countLabel: AppLocalizations.of(context)!.hits,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              AppLocalizations.of(context)!.clients,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            StatisticsListContent(
                              type: "clients", 
                              countLabel: AppLocalizations.of(context)!.requests,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ],
          );
        
        case LoadStatus.error: 
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statistics),
      ),
      body: body()
    );
  }
}