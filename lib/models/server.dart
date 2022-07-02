class Server {
  final String address;
  String alias;
  String password;
  String? pwHash;
  bool defaultServer;
  bool? enabled;

  Server({
    required this.address,
    required this.alias,
    required this.password,
    this.pwHash,
    required this.defaultServer,
    this.enabled,
  });
}