import 'dart:convert';

OverTimeData overTimeDataFromJson(String str) => OverTimeData.fromJson(json.decode(str));

String overTimeDataToJson(OverTimeData data) => json.encode(data.toJson());

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

  Map<String, dynamic> toJson() => {
    "domains_over_time": Map.from(domainsOverTime).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "ads_over_time": Map.from(adsOverTime).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}