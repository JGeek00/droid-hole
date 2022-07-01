import 'dart:convert';

import 'package:droid_hole/functions/charts_data_functions.dart';

RealtimeStatus realtimeStatusFromJson(String str) => RealtimeStatus.fromJson(json.decode(str));

class RealtimeStatus {
  final int domainsBeingBlocked;
  final int dnsQueriesToday;
  final int adsBlockedToday;
  final double adsPercentageToday;
  final int uniqueDomains;
  final int queriesForwarded;
  final int queriesCached;
  final int clientsEverSeen;
  final int uniqueClients;
  final int dnsQueriesAllTypes;
  final int replyUnknown;
  final int replyNodata;
  final int replyNxdomain;
  final int replyCname;
  final int replyIp;
  final int replyDomain;
  final int replyRrname;
  final int replyServfail;
  final int replyRefused;
  final int replyNotimp;
  final int replyOther;
  final int replyDnssec;
  final int replyNone;
  final int replyBlob;
  final int dnsQueriesAllReplies;
  final int privacyLevel;
  final String status;
  final Map<String, int> topQueries;
  final Map<String, int> topAds;
  final Map<String, int> topSources;
  final Map<String, int> topSourcesBlocked;
  final Map<String, double> forwardDestinations;
  final Map<String, double> queryTypes;
    
  RealtimeStatus({
    required this.domainsBeingBlocked,
    required this.dnsQueriesToday,
    required this.adsBlockedToday,
    required this.adsPercentageToday,
    required this.uniqueDomains,
    required this.queriesForwarded,
    required this.queriesCached,
    required this.clientsEverSeen,
    required this.uniqueClients,
    required this.dnsQueriesAllTypes,
    required this.replyUnknown,
    required this.replyNodata,
    required this.replyNxdomain,
    required this.replyCname,
    required this.replyIp,
    required this.replyDomain,
    required this.replyRrname,
    required this.replyServfail,
    required this.replyRefused,
    required this.replyNotimp,
    required this.replyOther,
    required this.replyDnssec,
    required this.replyNone,
    required this.replyBlob,
    required this.dnsQueriesAllReplies,
    required this.privacyLevel,
    required this.status,
    required this.topQueries,
    required this.topAds,
    required this.topSources,
    required this.topSourcesBlocked,
    required this.forwardDestinations,
    required this.queryTypes,
  });

  factory RealtimeStatus.fromJson(Map<String, dynamic> json) => RealtimeStatus(
    domainsBeingBlocked: json["domains_being_blocked"],
    dnsQueriesToday: json["dns_queries_today"],
    adsBlockedToday: json["ads_blocked_today"],
    adsPercentageToday: json["ads_percentage_today"].toDouble(),
    uniqueDomains: json["unique_domains"],
    queriesForwarded: json["queries_forwarded"],
    queriesCached: json["queries_cached"],
    clientsEverSeen: json["clients_ever_seen"],
    uniqueClients: json["unique_clients"],
    dnsQueriesAllTypes: json["dns_queries_all_types"],
    replyUnknown: json["reply_UNKNOWN"],
    replyNodata: json["reply_NODATA"],
    replyNxdomain: json["reply_NXDOMAIN"],
    replyCname: json["reply_CNAME"],
    replyIp: json["reply_IP"],
    replyDomain: json["reply_DOMAIN"],
    replyRrname: json["reply_RRNAME"],
    replyServfail: json["reply_SERVFAIL"],
    replyRefused: json["reply_REFUSED"],
    replyNotimp: json["reply_NOTIMP"],
    replyOther: json["reply_OTHER"],
    replyDnssec: json["reply_DNSSEC"],
    replyNone: json["reply_NONE"],
    replyBlob: json["reply_BLOB"],
    dnsQueriesAllReplies: json["dns_queries_all_replies"],
    privacyLevel: json["privacy_level"],
    status: json["status"],
    topQueries: (json["top_queries"].runtimeType != List<dynamic>)
      ? Map.from(json["top_queries"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    topAds: (json["top_ads"].runtimeType != List<dynamic>)
      ? Map.from(json["top_ads"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    topSources: (json["top_sources"].runtimeType != List<dynamic>)
      ? Map.from(json["top_sources"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    topSourcesBlocked: (json["top_sources_blocked"].runtimeType != List<dynamic>)
      ? Map.from(json["top_sources_blocked"]).map((k, v) => MapEntry<String, int>(k, v))
      : {},
    forwardDestinations: (json["forward_destinations"].runtimeType != List<dynamic>) 
      ? sortValues(
          removeZeroValues(
            Map.from(json["forward_destinations"]).map((k, v) => MapEntry<String, double>(k, v.toDouble()))
          )
        )
      : {},
    queryTypes: (json["querytypes"].runtimeType != List<dynamic>)
      ? sortValues(
          removeZeroValues(
            Map.from(json["querytypes"]).map((k, v) => MapEntry<String, double>(k, v.toDouble()))
          )
        )
      : {}
  );
}