import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class QueriesLastHours extends StatelessWidget {
  final Map<String, dynamic> data;

  const QueriesLastHours({
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
      lineBarsData: [
        LineChartBarData(
          spots: data['data']['ads'],
          color: Colors.blue,
          isCurved: true,
          barWidth: 2,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.2)
          ),
        ),
        LineChartBarData(
          spots: data['data']['domains'],
          color: Colors.green,
          isCurved: true,
          barWidth: 2,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.2)
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: selectedTheme == ThemeMode.light
            ? const Color.fromRGBO(220, 220, 220, 0.9)
            : const Color.fromRGBO(35, 35, 35, 0.9),
          getTooltipItems: (items) => [
            LineTooltipItem(
              "Blocked: ${items[0].y.toInt().toString()}", 
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green
              )
            ),
            LineTooltipItem(
              "Not blocked: ${items[1].y.toInt().toString()}", 
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue
              )
            ),
          ]
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    Map<String, dynamic> formatData(Map<String, dynamic> data) {
      final List<FlSpot> domains = [];
      final List<FlSpot> ads = [];

      int xPosition = 0;
      int topPoint = 0;
      data['domains_over_time'].keys.forEach((key) {
        if (data['domains_over_time'][key] > topPoint) {
          topPoint = data['domains_over_time'][key];
        }
        domains.add(
          FlSpot(
            xPosition.toDouble(), 
            data['domains_over_time'][key].toDouble()
          )
        );
        xPosition++;
      });
      
      xPosition = 0;
      data['ads_over_time'].keys.forEach((key) {
        ads.add(
          FlSpot(
            xPosition.toDouble(), 
            data['ads_over_time'][key].toDouble()
          )
        );
        xPosition++;
      });

      return {
        'data': {
          'domains': domains,
          'ads': ads
        },
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