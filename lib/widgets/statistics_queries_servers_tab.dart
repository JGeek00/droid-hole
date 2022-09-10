import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/no_data_chart.dart';
import 'package:droid_hole/widgets/custom_pie_chart.dart';
import 'package:droid_hole/widgets/pie_chart_legend.dart';

import 'package:droid_hole/providers/servers_provider.dart';

class QueriesServersTab extends StatelessWidget {
  const QueriesServersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          serversProvider.getRealtimeStatus!.queryTypes.isEmpty == false
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black12,
                        )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.queryTypes,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: width-40,
                      child: CustomPieChart(
                        data: serversProvider.getRealtimeStatus!.queryTypes,
                      )
                    ),
                    const SizedBox(height: 20),
                    PieChartLegend(
                      data: serversProvider.getRealtimeStatus!.queryTypes,
                      dataUnit: '%',
                    )
                  ]
                ),
              )
            : NoDataChart(
              topLabel: AppLocalizations.of(context)!.queryTypes,
            ),
          if (
            serversProvider.getRealtimeStatus!.queryTypes.isEmpty == false &&
            serversProvider.getRealtimeStatus!.forwardDestinations.isEmpty == false
          )  Container(
            width: double.maxFinite,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          serversProvider.getRealtimeStatus!.forwardDestinations.isEmpty == false
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black12,
                        )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.upstreamServers,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: width-40,
                      child: CustomPieChart(
                        data: serversProvider.getRealtimeStatus!.forwardDestinations,
                      )
                    ),
                    const SizedBox(height: 20),
                    PieChartLegend(
                      data: serversProvider.getRealtimeStatus!.forwardDestinations,
                      dataUnit: '%',
                    )
                  ] 
                ),
              )
            : NoDataChart(
              topLabel: AppLocalizations.of(context)!.upstreamServers,
            ),
        ],
      ),
    );
  }
}