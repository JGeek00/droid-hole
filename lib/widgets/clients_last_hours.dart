import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class ClientsLastHours extends StatelessWidget {
  final Map<String, dynamic> data;

  const ClientsLastHours({
    Key? key,
    required this.data,
  }) : super(key: key);

  LineChartData mainData(Map<String, dynamic> data, ThemeMode selectedTheme) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (data['topPoint']/5).toDouble(),
        getDrawingHorizontalLine: (value) => FlLine(
          color: selectedTheme == ThemeMode.light
            ? Colors.black12
            : Colors.white12,
          strokeWidth: 1
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (data['topPoint']/5).toDouble(),
            reservedSize: 35,
            getTitlesWidget: (value, widget) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          top: BorderSide(
            color: selectedTheme == ThemeMode.light
              ? Colors.black12
              : Colors.white12,
            width: 1
          ),
          bottom: BorderSide(
            color: selectedTheme == ThemeMode.light
              ? Colors.black12
              : Colors.white12,
            width: 1
          ),
        )
      ),
      lineBarsData: data['data'],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: selectedTheme == ThemeMode.light
            ? const Color.fromRGBO(220, 220, 220, 1)
            : const Color.fromRGBO(35, 35, 35, 1),
          maxContentWidth: 150,
          getTooltipItems: (items) => items.map(
            (item) =>  LineTooltipItem(
              "${data['clientsColors'][item.barIndex]['ip']}: ${item.y.toInt().toString()}", 
              TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: data['clientsColors'][item.barIndex]['color']
              )
            )
          ).toList(),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    Map<String, dynamic> formatData(Map<String, dynamic> data) {
      final List<LineChartBarData> items = [];
      final List<Map<String, dynamic>> clientsColors = [];
      int topPoint = 0;
      for (var i = 0; i < data['clients'].length; i++) {
        final List<FlSpot> client = [];
        int xPosition = 0;
        data['over_time'].keys.forEach((key) {
          if (data['over_time'][key][i] > topPoint) {
            topPoint = data['over_time'][key][i];
          }
          client.add(
            FlSpot(
              xPosition.toDouble(),
              data['over_time'][key][i].toDouble()
            )
          );
          xPosition++;
        });
        items.add(
          LineChartBarData(
            spots: client,
            color: data['clients'][i]['color'],
            isCurved: true,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: data['clients'][i]['color'].withOpacity(0.2)
            ),
          ),
        );
        clientsColors.add({
          'ip': data['clients'][i]['ip'],
          'color': data['clients'][i]['color']
        });
      }

      return {
        'data': items,
        'clientsColors': clientsColors,
        'topPoint': topPoint
      };
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: LineChart(
        mainData(formatData(data), appConfigProvider.selectedTheme)
      ),
    );
  }
}