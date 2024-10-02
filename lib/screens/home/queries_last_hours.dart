import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class QueriesLastHours extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool reducedData;

  const QueriesLastHours({
    super.key,
    required this.data,
    required this.reducedData,
  });

  LineChartData mainData(Map<String, dynamic> data, ThemeMode selectedTheme) {
    final double interval = (data['topPoint']/5).toDouble() > 0
      ? (data['topPoint']/5).toDouble()
      : data['topPoint'].toDouble() > 0
        ? data['topPoint'].toDouble()
        : 1.0;
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
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
        // Hidden bar to allow 3 items on tooltip
        LineChartBarData(
          spots: data['data']['domains'],
          color: Colors.transparent,
          barWidth: 0,
        ),
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
          getTooltipColor: (touchedSpot) => selectedTheme == ThemeMode.light
            ? const Color.fromRGBO(220, 220, 220, 0.9)
            : const Color.fromRGBO(35, 35, 35, 0.9),
          getTooltipItems: (items) => [
            LineTooltipItem(
              formatTimestampForChart(data['time'][items[0].x.toInt()]), 
              TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selectedTheme == ThemeMode.light 
                  ? Colors.black
                  : Colors.white
              )
            ),
            LineTooltipItem(
              "Not blocked: ${items[1].y.toInt().toString()}", 
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green
              )
            ),
            LineTooltipItem(
              "Blocked: ${items[2].y.toInt().toString()}", 
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
      List<String> domainsKeys = data['domains_over_time'].keys.toList();
      for (var i = 0; i < data['domains_over_time'].entries.length; reducedData == true ? i+=6 : i++) {
        if (data['domains_over_time'][domainsKeys[i]] > topPoint) {
          topPoint = data['domains_over_time'][domainsKeys[i]];
        }
        domains.add(
          FlSpot(
            xPosition.toDouble(), 
            data['domains_over_time'][domainsKeys[i]].toDouble()
          )
        );
        xPosition++;
      }
      
      xPosition = 0;
      List<String> adsKeys = data['ads_over_time'].keys.toList();
      for (var i = 0; i < data['ads_over_time'].entries.length; reducedData == true ? i+=6 : i++) {
        ads.add(
          FlSpot(
            xPosition.toDouble(), 
            data['ads_over_time'][adsKeys[i]].toDouble()
          )
        );
        xPosition++;
      }

      List<String> timestamps = [];
      final List<String> k = data['domains_over_time'].keys.toList();
      for (var i = 0; i < k.length; reducedData == true ? i+=6 : i++) {
        timestamps.add(k[i]);
      }

      return {
        'data': {
          'domains': domains,
          'ads': ads
        },
        'topPoint': topPoint,
        'time': timestamps
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