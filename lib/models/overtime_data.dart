import 'dart:convert';

OverTimeData overTimeDataFromJson(String str) => OverTimeData.fromJson(json.decode(str));

class OverTimeData {
  OverTimeData({
    required this.domainsOverTime,
    required this.adsOverTime,
  });

  final Map<String, int> domainsOverTime;
  final Map<String, int> adsOverTime;

  factory OverTimeData.fromJson(Map<String, dynamic> json) => OverTimeData(
    domainsOverTime: Map.from(json["domains_over_time"]).map((k, v) => MapEntry<String, int>(k, v)),
    adsOverTime: Map.from(json["ads_over_time"]).map((k, v) => MapEntry<String, int>(k, v)),
  );
}