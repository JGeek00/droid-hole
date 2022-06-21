class Server {
  final String address;
  String alias;
  String password;
  bool defaultServer;
  bool? enabled;

  Server({
    required this.address,
    required this.alias,
    required this.password,
    required this.defaultServer,
    this.enabled,
  });
}