class Server {
  final String address;
  String alias;
  String? token;
  bool defaultServer;
  bool? enabled;

  Server({
    required this.address,
    required this.alias,
    this.token,
    required this.defaultServer,
    this.enabled,
  });
}