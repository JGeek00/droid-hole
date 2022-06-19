import 'package:charts_flutter/flutter.dart' as charts;

class TimeRecord {
  final String time;
  final int value;

  const TimeRecord({
    required this.time,
    required this.value
  });
}

List<charts.Series<dynamic, String>> formatChartData(Map<dynamic, dynamic> data) {

  final blockedData = [
    TimeRecord(time: "1", value: 1),
  ];

  final totalData = [
    TimeRecord(time: "1", value: 2),
  ];

  return [
    charts.Series<TimeRecord, String>(
      id: 'Blocked',
      domainFn: (TimeRecord item, _) => item.time,
      measureFn: (TimeRecord item, _) => item.value,
      data: blockedData,
    ),
    charts.Series<TimeRecord, String>(
      id: 'Total',
      domainFn: (TimeRecord item, _) => item.time,
      measureFn: (TimeRecord item, _) => item.value,
      data: totalData,
    ),
  ];
}