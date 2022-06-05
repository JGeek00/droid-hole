import 'package:flutter/material.dart';

import 'package:droid_hole/providers/connected_server_provider.dart';

import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  ConnectedServerProvider? _connectedServerProvider;

  update(ConnectedServerProvider? connectedServerProvider) {
    if (connectedServerProvider != null) {
      _connectedServerProvider = connectedServerProvider;
    }
  }

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