import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartColumn {
  final String label;
  final int value;
  final Map<dynamic, dynamic>? client;
  final Color? color;

  const ChartColumn({
    required this.label,
    required this.value,
    this.client,
    this.color,
  });
}

List<charts.Series<dynamic, String>> formatQueriesChart(Map<dynamic, dynamic> data) {
  final List<ChartColumn> totalData = [];
  final List<ChartColumn> blockedData = [];

  data['domains_over_time'].keys.forEach((key) => {
    totalData.add(
      ChartColumn(
        label: key,
        value: data['domains_over_time'][key]
      )
    )
  });
  data['ads_over_time'].keys.forEach((key) => {
    blockedData.add(
      ChartColumn(
        label: key,
        value: data['ads_over_time'][key]
      )
    )
  });

  return [
    charts.Series<ChartColumn, String>(
      id: 'Blocked',
      domainFn: (ChartColumn item, _) => item.label,
      measureFn: (ChartColumn item, _) => item.value,
      data: blockedData,
      fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    ),
    charts.Series<ChartColumn, String>(
      id: 'Total',
      domainFn: (ChartColumn item, _) => item.label,
      measureFn: (ChartColumn item, _) => item.value,
      data: totalData,
      fillColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
    ),
  ];
}

List<charts.Series<dynamic, String>> formatClientsChart(Map<dynamic, dynamic> data) {
  final List<List<ChartColumn>> items = [];
  for (var i = 0; i < data['clients'].length; i++) {
    final List<ChartColumn> client = [];
    data['over_time'].keys.forEach((key) {
      client.add(
        ChartColumn(
          label: key, 
          value: data['over_time'][key][i],
          client: data['clients'][i],
          color: data['clients'][i]['color']
        )
      );
    });
    items.add(client);
  }

  return [
    ...items.asMap().entries.map((item) => charts.Series<ChartColumn, String>(
      id: "${item.key}",
      domainFn: (ChartColumn item, _) => item.label,
      measureFn: (ChartColumn item, _) => item.value,
      data: item.value,
      fillColorFn: (c, i) => charts.Color(
        r: c.color!.red, 
        g: c.color!.green, 
        b: c.color!.blue
      )
    )),
  ];
}