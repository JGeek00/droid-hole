class Server {
  final String address;
  final String? alias;
  final String token;
  final bool defaultServer;

  const Server({
    required this.address,
    this.alias,
    required this.token,
    required this.defaultServer,
  });
}