import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BarChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;

  const BarChart({
    Key? key,
    required this.seriesList
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return charts.BarChart(
      seriesList,
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      domainAxis: const charts.OrdinalAxisSpec(
        showAxisLine: true,
        renderSpec: charts.NoneRenderSpec()
      ),
    );
  }
}