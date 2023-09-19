class Log {
  final DateTime dateTime;
  final String type;
  final String url;
  final String device;
  final String? status;
  final String? replyType;
  final BigInt replyTime;
  final String? answeredBy;

  const Log({
    required this.dateTime,
    required this.type,
    required this.url,
    required this.device,
    required this.status,
    required this.replyType,
    required this.replyTime,
    this.answeredBy,
  });

  static const List<String> replyTypes = [
    "N/A",
    "NODATA",
    "NXDOMAIN",
    "CNAME",
    "IP",
    "DOMAIN",
    "RRNAME",
    "SERVFAIL",
    "REFUSED",
    "NOTIMP",
    "upstream error",
    "DNSSEC",
    "NONE",
    "BLOB",
  ];

  factory Log.fromJson(List data) => Log(
    dateTime: DateTime.fromMillisecondsSinceEpoch((int.parse(data[0]))*1000),
    type: data[1],
    url: data[2],
    device: data[3],
    status: data[4],
    replyType: data[6] != null ? replyTypes[int.parse(data[6])] : null,
    replyTime: BigInt.parse(data[7]),
    answeredBy: data[4] == '2' ? data.length >= 10 ? data[10] : null : null
  );
}