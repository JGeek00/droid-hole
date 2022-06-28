import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PieItem {
  final String label;
  final int value;
  Color? color;

  PieItem({
    required this.label,
    required this.value,
    this.color,
  });
}

List<charts.Series<dynamic, String>> formatQueryTypesChart(Map<dynamic, dynamic> data) {
  final List<PieItem> queryTypes = [];

  for (var key in data.keys) {
    {
      queryTypes.add(
        PieItem(
          label: key,
          value: data[key]
        )
      );
    }
  }

  return [
    charts.Series<PieItem, String>(
      id: 'Queries',
      domainFn: (PieItem item, _) => item.label,
      measureFn: (PieItem item, _) => item.value,
      data: queryTypes,
      fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    ),
  ];
}