class Server {
  final String address;
  String? alias;
  String token;
  bool defaultServer;
  bool? enabled;

  Server({
    required this.address,
    this.alias,
    required this.token,
    required this.defaultServer,
    this.enabled,
  });
}