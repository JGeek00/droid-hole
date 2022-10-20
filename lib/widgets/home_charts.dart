import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/no_data_chart.dart';
import 'package:droid_hole/widgets/queries_last_hours.dart';
import 'package:droid_hole/widgets/clients_last_hours.dart';

import 'package:droid_hole/constants/colors.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class HomeCharts extends StatelessWidget {
  const HomeCharts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    final List<String> clientsListIps = serversProvider.getRealtimeStatus != null
      ? convertFromMapToList(serversProvider.getRealtimeStatus!.topSources).map(
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

    List<Widget> generateLegend(List values) {
      List<Widget> generateRow(int length) {
        Widget generateItem(int i, int itemsPerRow) {
          Color getColor(Client client, int index) {
            final exists = clientsListIps.indexOf(client.ip);
            if (exists >= 0) {
              return colors[exists];
            }
            else {
              return client.color;
            }
          }
          return Container(
            width: appConfigProvider.oneColumnLegend == true
              ? ((width-60)/itemsPerRow)
              : itemsPerRow == 2 
                ? ((width-60)/itemsPerRow)
                : ((width-100)/itemsPerRow),
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: getColor(serversProvider.getOvertimeData!.clients[i], i)
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    serversProvider.getOvertimeData!.clients[i].ip,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          );
        }

        List<Widget> widgets = [];
        if (appConfigProvider.oneColumnLegend == true) {
          for (var i = 0; i < length; i++) {
            widgets.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      generateItem(i, 1),
                    ],
                  ),
                ],
              )
            );
          }
        }
        else {
          if (!(orientation == Orientation.landscape && height < 1000)) {
            for (var i = 0; i < length; i+=2) {
              widgets.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        generateItem(i, 2),
                        i+1 < length ? generateItem(i+1, 2) : const SizedBox(),
                      ],
                    ),
                  ],
                )
              );
            }
          }
          else {
            for (var i = 0; i < length; i+=4) {
              widgets.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        generateItem(i, 4),
                        i+1 < length ? generateItem(i+1, 4) : const SizedBox(),
                        i+2 < length ? generateItem(i+2, 4) : const SizedBox(),
                        i+3 < length ? generateItem(i+3, 4) : const SizedBox(),
                      ],
                    ),
                  ],
                )
              );
            }
          }
        }
        return widgets;
      }

      if (values.length % 2 == 0) {
        return generateRow(values.length);
      }
      else {
        return generateRow(values.length);
      }
    }

    switch (serversProvider.getOvertimeDataLoadStatus) {
      case 0:
        return SizedBox(
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
                ),
              )
            ],
          ),
        );

      case 1:
        return Column(
          children: [
            serversProvider.getOvertimeDataJson!['domains_over_time'].keys.length > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.totalQueries24,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.maxFinite,
                        height: 350,
                        child: QueriesLastHours(
                          data: serversProvider.getOvertimeDataJson!,
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
                  ),
                )
              : NoDataChart(
                  topLabel: AppLocalizations.of(context)!.totalQueries24,
                ),
            const SizedBox(height: 20),
            serversProvider.getOvertimeDataJson!['over_time'].keys.length > 0 &&
            serversProvider.getOvertimeDataJson!['clients'].length > 0 
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.clientActivity24,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ClientsLastHours(
                            realtimeListIps: clientsListIps,
                            data: serversProvider.getOvertimeDataJson!,
                            reducedData: appConfigProvider.reducedDataCharts,
                            hideZeroValues: appConfigProvider.hideZeroValues,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: generateLegend(serversProvider.getOvertimeData!.clients),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              )
              : NoDataChart(
                  topLabel: AppLocalizations.of(context)!.clientActivity24,
                ),
          ],
        );

      case 2: 
        return SizedBox(
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
                style: const TextStyle(
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
}