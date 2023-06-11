import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/statistics/custom_pie_chart.dart';
import 'package:droid_hole/screens/statistics/no_data_chart.dart';
import 'package:droid_hole/screens/statistics/pie_chart_legend.dart';
import 'package:droid_hole/widgets/section_label.dart';
import 'package:droid_hole/widgets/tab_content.dart';

import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/conversions.dart';

class StatisticsList extends StatelessWidget {
  final String countLabel;
  final String type;
  final Future<void> Function() onRefresh;

  const StatisticsList({
    Key? key,
    required this.countLabel,
    required this.type,
    required this.onRefresh
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void navigateFilter(String value) {
      if (type == 'clients') {
        final isContained = filtersProvider.totalClients.where((client) => value.contains(client)).toList();
        if (isContained.isNotEmpty) {
          filtersProvider.setSelectedClients([isContained[0]]);
          appConfigProvider.setSelectedTab(2);
        }
      }
      if (type == 'domains') {
        filtersProvider.setSelectedDomain(value);
        appConfigProvider.setSelectedTab(2);
      }
    }

    Widget listViewMode(List<Map<String, dynamic>> values) {
      int totalHits = 0;
      for (var item in values) {
        totalHits = totalHits + item['value'].toInt() as int;
      }

      return Column(
        children: [
          ...values.map((item) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => navigateFilter(item['label']),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width - 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 15
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$countLabel ${item['value'].toInt().toString()}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: LinearPercentIndicator(
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 500,
                        curve: Curves.easeOut,
                        percent: (item['value']/totalHits).toDouble(),
                        barRadius: const Radius.circular(5),
                        progressColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )).toList()
        ],
      );
    }

    Widget pieChertViewMode(List<Map<String, dynamic>> values) {
      Map<String, double> items = {};
      Map<String, int> legend = {};
      for (var item in values) {
        items = {
          ...items,
          item['label']: item['value'].toDouble()
        };
        legend = {
          ...legend,
          item['label']: item['value'].toInt()
        };
      }
      return Column(
        children: [
          const SizedBox(height: 10),
          CustomPieChart(
            data: items
          ),
          const SizedBox(height: 20),
          PieChartLegend(
            data: legend,
            onValueTap: (value) => navigateFilter(value),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    Widget generateList(Map<String, int> values, String label) {
      final topQueriesList = convertFromMapToList(values);
      
      return Column(
        children: [
          SectionLabel(
            label: label,
            padding: const EdgeInsets.only(
              top: 24,
              left: 16,
              bottom: 16
            ),
          ),
          appConfigProvider.statisticsVisualizationMode == 0
            ? listViewMode(topQueriesList)
            : pieChertViewMode(topQueriesList)
        ],
      );
    }

    return CustomTabContent(
      loadingGenerator: () => SizedBox(
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
      ), 
      contentGenerator: () {
        if (type == "domains") {
          return [
            statusProvider.getRealtimeStatus!.topQueries.isNotEmpty
              ? generateList(
                  statusProvider.getRealtimeStatus!.topQueries, 
                  AppLocalizations.of(context)!.topPermittedDomains
                )
              : NoDataChart(
                topLabel: AppLocalizations.of(context)!.noData
              ),
            statusProvider.getRealtimeStatus!.topAds.isNotEmpty
              ? generateList(
                  statusProvider.getRealtimeStatus!.topAds, 
                  AppLocalizations.of(context)!.topBlockedDomains
                )
              : NoDataChart(
                  topLabel: AppLocalizations.of(context)!.noData
                ),
          ];
        }
        else if (type == "clients") {
          return [
            statusProvider.getRealtimeStatus!.topSources.isNotEmpty
              ? generateList(
                  statusProvider.getRealtimeStatus!.topSources, 
                  AppLocalizations.of(context)!.topClients
                )
              : NoDataChart(
                topLabel: AppLocalizations.of(context)!.noData
              ),
            statusProvider.getRealtimeStatus!.topSourcesBlocked.isNotEmpty
              ? generateList(
                  statusProvider.getRealtimeStatus!.topSourcesBlocked, 
                  AppLocalizations.of(context)!.topClientsBlocked
                )
              : NoDataChart(
                  topLabel: AppLocalizations.of(context)!.noData
                ),
          ];
        }
        else {
          return [];
        }
      },
      errorGenerator: () => SizedBox(
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
      ), 
      loadStatus: statusProvider.getStatusLoading, 
      onRefresh: onRefresh
    );
  }
}