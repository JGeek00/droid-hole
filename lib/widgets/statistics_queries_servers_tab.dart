import 'package:droid_hole/widgets/no_data_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_pie_chart.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/constants/colors.dart';

class QueriesServersTab extends StatelessWidget {
  const QueriesServersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final width = MediaQuery.of(context).size.width;

    List<Widget> _generateLegendList(Map<String, double> data) {
      List<Widget> items = [];
      int index = 0;
      data.forEach((key, value) {
        items.add(
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: colors[index]
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: width-160,
                      child: Text(
                        key,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 65,
                  child: Text(
                    "${value.toString()} %",
                    textAlign: TextAlign.end,
                  )
                ),
              ],
            ),
          ),
        );
        index++;
      });
      return items;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          serversProvider.getRealtimeStatus!.queryTypes.isEmpty == false
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.queryTypes,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
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
                    Column(
                      children: _generateLegendList(serversProvider.getRealtimeStatus!.queryTypes),
                    ),
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
                    Text(
                      AppLocalizations.of(context)!.upstreamServers,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
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
                    Column(
                      children: _generateLegendList(serversProvider.getRealtimeStatus!.forwardDestinations),
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