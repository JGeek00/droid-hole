import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/statistics/no_data_chart.dart';
import 'package:droid_hole/screens/home/queries_last_hours.dart';
import 'package:droid_hole/screens/home/clients_last_hours.dart';
import 'package:droid_hole/widgets/section_label.dart';

import 'package:droid_hole/constants/colors.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class HomeCharts extends StatelessWidget {
  const HomeCharts({super.key});

  bool checkExistsData(Map<String, dynamic> data) {
    bool exists = false;
    for (var element in data.keys) {
      if (data[element] > 0) {
        exists = true;
        break;
      }
    } 
    return exists;
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    final List<String> clientsListIps = statusProvider.getRealtimeStatus != null
      ? convertFromMapToList(statusProvider.getRealtimeStatus!.topSources).map(
          (client) {
            final split = client['label'].toString().split('|');
            if (split.length > 1) {
              return split[1];
            }
            else {
              return client['label'].toString();
            }
          }
        ).toList()
      : [];

    Color getColor(Client client, int index) {
      final exists = clientsListIps.indexOf(client.ip);
      if (exists >= 0) {
        return colors[exists];
      }
      else {
        return client.color;
      }
    }

    switch (statusProvider.getOvertimeDataLoadStatus) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.maxFinite,
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.loadingCharts,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          ),
        );

      case 1:
        return Wrap(
          children: [
            FractionallySizedBox(
              widthFactor: width > 700 ? 0.5 : 1,
              child: checkExistsData(statusProvider.getOvertimeDataJson!['domains_over_time']) && checkExistsData(statusProvider.getOvertimeDataJson!['ads_over_time'])
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(label: AppLocalizations.of(context)!.totalQueries24),
                    Container(
                      width: double.maxFinite,
                      height: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: QueriesLastHours(
                        data: statusProvider.getOvertimeDataJson!,
                        reducedData: appConfigProvider.reducedDataCharts,
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.blocked)
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.notBlocked)
                          ],
                        ),
                      ],
                    )
                  ],
                )
                : NoDataChart(
                    topLabel: AppLocalizations.of(context)!.totalQueries24,
                  ),
            ),
            FractionallySizedBox(
              widthFactor: width > 700 ? 0.5 : 1,
              child: statusProvider.getOvertimeDataJson!['over_time'].keys.length > 0 &&
                statusProvider.getOvertimeDataJson!['clients'].length > 0 
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(label: AppLocalizations.of(context)!.clientActivity24),
                          Container(
                            width: double.maxFinite,
                            height: 350,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClientsLastHours(
                              realtimeListIps: clientsListIps,
                              data: statusProvider.getOvertimeDataJson!,
                              reducedData: appConfigProvider.reducedDataCharts,
                              hideZeroValues: appConfigProvider.hideZeroValues,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Wrap(
                          runSpacing: 16,
                          children: statusProvider.getOvertimeData!.clients.asMap().entries.map((entry) => FractionallySizedBox(
                            widthFactor: width > 1000 && statusProvider.getOvertimeData!.clients.length > 3 
                              ? 0.33 
                              : width > 350 
                                ? 0.5
                                : 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: getColor(entry.value, entry.key)
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (entry.value.name != '') ...[
                                        Text(
                                          entry.value.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                      Text(
                                        entry.value.ip,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  )
                  : NoDataChart(
                      topLabel: AppLocalizations.of(context)!.clientActivity24,
                    ),
            )
          ],
        );

      case 2: 
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.maxFinite,
            height: 280,
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
                  AppLocalizations.of(context)!.chartsNotLoaded,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          ),
        );

      default:
        return const SizedBox();
      }
  }
}