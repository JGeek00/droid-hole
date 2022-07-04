import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:droid_hole/functions/colors.dart';

OverTimeData overTimeDataFromJson(String str) => OverTimeData.fromJson(json.decode(str));

String overTimeDataToJson(OverTimeData data) => json.encode(data.toJson());

class OverTimeData {
  OverTimeData({
    required this.domainsOverTime,
    required this.adsOverTime,
    required this.clients,
    required this.overTime,
  });

  final Map<String, int> domainsOverTime;
  final Map<String, int> adsOverTime;
  final List<Client> clients;
  final Map<String, List<int>> overTime;

  factory OverTimeData.fromJson(Map<String, dynamic> json) => OverTimeData(
    domainsOverTime: (json["domains_over_time"].runtimeType != List<dynamic>) 
      ? Map.from(json["domains_over_time"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    adsOverTime: (json["ads_over_time"].runtimeType != List<dynamic>) 
      ? Map.from(json["ads_over_time"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    clients: List<Client>.from(json["clients"].map((x) => Client.fromJson(x))),
    overTime: (json["over_time"].runtimeType != List<dynamic>) 
      ? Map.from(json["over_time"]).map((k, v) => MapEntry<String, List<int>>(k, List<int>.from(v.map((x) => x))))
      : {},
  );

  Map<String, dynamic> toJson() => {
    "domains_over_time": Map.from(domainsOverTime).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "ads_over_time": Map.from(adsOverTime).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "clients": List<dynamic>.from(clients.map((x) => x.toJson())),
    "over_time": Map.from(overTime).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
  };
}

class Client {
  Client({
    required this.name,
    required this.ip,
    required this.color,
  });

  final String name;
  final String ip;
  final Color color;

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    name: json["name"],
    ip: json["ip"],
    color: generateRandomColor()
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "ip": ip,
    "color": color,
  };
}