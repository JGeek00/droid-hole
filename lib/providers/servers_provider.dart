import 'package:droid_hole/functions/conversions.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

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
  Database? _dbInstance;

  List<Server> get getServersList {
    return _serversList;
  }

  void addServer(Server server) {
    _serversList.add(server);
    saveToDb(server);
    notifyListeners();
  }

  void removeServer(String serverAddress) {
    List<Server> newServers = _serversList.where((server) => server.address != serverAddress).toList();
    _serversList = newServers;
    notifyListeners();
  }

  void saveFromDb(List<Map<String, dynamic>>? servers) {
    if (servers != null) {
      for (var server in servers) {
        _serversList.add(
          Server(
            address: server['address'], 
            alias: server['alias'],
            token: server['token'], 
            defaultServer: convertFromIntToBool(server['isDefaultServer'])!,
          )
        );
      }
    }
    notifyListeners();
  }

  void saveToDb(Server server) async {
    try {
      await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO servers (address, alias, token, isDefaultServer) VALUES ("${server.address}", "${server.alias}", "${server.token}", 0)',
        );
      });
    } catch (e) {
      print(e);
    }
  }

  void setDbInstance(Database db) {
    _dbInstance = db;
  }
}