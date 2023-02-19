class Server {
  final String address;
  String alias;
  String? token;
  bool defaultServer;
  bool? enabled;
  String? basicAuthUser;
  String? basicAuthPassword;

  Server({
    required this.address,
    required this.alias,
    this.token,
    required this.defaultServer,
    this.enabled,
    this.basicAuthUser,
    this.basicAuthPassword
  });
}