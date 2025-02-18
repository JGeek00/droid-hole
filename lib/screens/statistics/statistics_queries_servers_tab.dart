import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/statistics/no_data_chart.dart';
import 'package:droid_hole/screens/statistics/pie_chart_legend.dart';
import 'package:droid_hole/screens/statistics/custom_pie_chart.dart';
import 'package:droid_hole/widgets/tab_content.dart';
import 'package:droid_hole/widgets/section_label.dart';

import 'package:droid_hole/providers/status_provider.dart';

class QueriesServersTab extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const QueriesServersTab({
    super.key,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);

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
      contentGenerator: () => [
        const QueriesServersTabContent()
      ], 
      errorGenerator: () =>  SizedBox(
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

class QueriesServersTabContent extends StatelessWidget {
  const QueriesServersTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);

    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        statusProvider.getRealtimeStatus!.queryTypes.isEmpty == false
          ? Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  SectionLabel(
                    label: AppLocalizations.of(context)!.queryTypes,
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      bottom: 24
                    ),
                  ),
                  if (width > 700) Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 200,
                            maxHeight: 200
                          ),
                          child: CustomPieChart(
                            data: statusProvider.getRealtimeStatus!.queryTypes,
                          ),
                        )
                      ),
                      Expanded(
                        flex: 3,
                        child: PieChartLegend(
                          data: statusProvider.getRealtimeStatus!.queryTypes,
                          dataUnit: '%',
                        ),
                      )
                    ],
                  ),
                  if (width <= 700) ...[
                    SizedBox(
                      width: width-40,
                      child: CustomPieChart(
                        data: statusProvider.getRealtimeStatus!.queryTypes,
                      )
                    ),
                    const SizedBox(height: 20),
                    PieChartLegend(
                      data: statusProvider.getRealtimeStatus!.queryTypes,
                      dataUnit: '%',
                    )
                  ]
                ]
              ),
            )
          : NoDataChart(
            topLabel: AppLocalizations.of(context)!.queryTypes,
          ),
        statusProvider.getRealtimeStatus!.forwardDestinations.isEmpty == false
          ? Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  SectionLabel(
                    label: AppLocalizations.of(context)!.upstreamServers,
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      bottom: 24
                    ),
                  ),
                  if (width > 700) Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 200,
                            maxHeight: 200
                          ),
                          child: CustomPieChart(
                            data: statusProvider.getRealtimeStatus!.forwardDestinations,
                          )
                        )
                      ),
                      Expanded(
                        flex: 3,
                        child: PieChartLegend(
                          data: statusProvider.getRealtimeStatus!.forwardDestinations,
                          dataUnit: '%',
                        ),
                      )
                    ],
                  ),
                  if (width <= 700) ...[
                    SizedBox(
                      width: width-40,
                      child: CustomPieChart(
                        data: statusProvider.getRealtimeStatus!.forwardDestinations,
                      )
                    ),
                    const SizedBox(height: 20),
                    PieChartLegend(
                      data: statusProvider.getRealtimeStatus!.forwardDestinations,
                      dataUnit: '%',
                    )
                  ]
                ] 
              ),
            )
          : NoDataChart(
            topLabel: AppLocalizations.of(context)!.upstreamServers,
          ),
      ],
    );
  }
}