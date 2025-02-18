import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:droid_hole/constants/colors.dart';


class CustomPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CustomPieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: data,
      animationDuration: const Duration(milliseconds: 800),
      chartRadius: MediaQuery.of(context).size.width / 3,
      colorList: colors,
      initialAngleInDegree: 270,
      chartType: ChartType.ring,
      ringStrokeWidth: 20,
      legendOptions: const LegendOptions(
        showLegends: false
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValues: false,
      ),
    );
  }
}