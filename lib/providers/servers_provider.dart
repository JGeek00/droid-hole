import 'package:droid_hole/functions/conversions.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  List<Server> _serversList = [];
  Database? _dbInstance;

  Server? _connectedServer;

  List<Server> get getServersList {
    return _serversList;
  }

  Server? get connectedServer {
    return _connectedServer;
  }

  void addServer(Server server) {
    _serversList.add(server);
    saveToDb(server);
    notifyListeners();
  }

  void removeServer(String serverAddress) {
    _connectedServer = null;
    List<Server> newServers = _serversList.where((server) => server.address != serverAddress).toList();
    _serversList = newServers;
    removeFromDb(serverAddress);
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

  void removeFromDb(String address) async {
    try {
      await _dbInstance!.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM servers WHERE address = "$address"',
        );
      });
    } catch (e) {
      print(e);
    }
  }

  void setConnectedServer(Server server) {
    _connectedServer = server;
    notifyListeners();
  }

  void updateConnectedServerStatus(bool enabled) {
    _connectedServer!.enabled = enabled;
    notifyListeners();
  }

  void setDbInstance(Database db) {
    _dbInstance = db;
  }

  Future deleteDbData() async {
    _serversList = [];
    _connectedServer = null;
    try {
      await _dbInstance!.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM servers',
        );
      });
    } catch (e) {
      print(e);
    }
  }
}