import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/statistics_top_bar.dart';
import 'package:droid_hole/widgets/custom_pie_chart.dart';

import 'package:droid_hole/constants/colors.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                    Text(
                      key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
                Text("${value.toString()} %"),
              ],
            ),
          ),
        );
        index++;
      });
      return items;
    }

    Widget _queriesServersTab() {
      return SizedBox(
        width: width,
        height: height-300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (serversProvider.getRealtimeStatus!.queryTypes.isEmpty == false) Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Query types",
                      style: TextStyle(
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
              ), 
              if (
                serversProvider.getRealtimeStatus!.queryTypes.isEmpty == false &&
                serversProvider.getRealtimeStatus!.forwardDestinations.isEmpty == false
              )  Container(
                width: double.maxFinite,
                height: 1,
                color: Colors.black12,
              ),
              if (serversProvider.getRealtimeStatus!.forwardDestinations.isEmpty == false) Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Upstream servers",
                      style: TextStyle(
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
            ],
          ),
        ),
      );
    }

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
              _queriesServersTab(),
              Container(
                child: Text("Tab 2"),
              ),
              Container(
                child: Text("Tab 3"),
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
        appBar: const PreferredSize(
          preferredSize: Size(double.maxFinite, 138),
          child: StatisticsTopBar()
        ),
        body: _generateBody()
      ),
    );
  }
}