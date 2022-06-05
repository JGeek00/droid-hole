import 'package:flutter/material.dart';

import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  List<Server> _serversList = [];

  List<Server> get getServersList {
    return _serversList;
  }

  void addServer(Server server) {
    _serversList.add(server);
    notifyListeners();
  }

  void removeServer(String serverIp) {
    List<Server> newServers = _serversList.where((server) => server.ipAddress != serverIp).toList();
    _serversList = newServers;
    notifyListeners();
  }
}