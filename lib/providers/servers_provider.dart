import 'dart:async';

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

  Future<bool> addServer(Server server) async {
    final saved = await saveToDb(server);
    if (saved == true) {
      if (server.defaultServer == true) {
        final defaultServer = await setDefaultServer(server);
        if (defaultServer == true) {
          _serversList.add(server);
          notifyListeners();
          return true;
        }
        else {
          return false;
        }
      }
      else {
        _serversList.add(server);
        notifyListeners();
        return true;
      }
    }
    else {
      return false;
    }
  }

  Future<bool> removeServer(String serverAddress) async {
    final result = await removeFromDb(serverAddress);
    if (result == true) {
      _connectedServer = null;
      List<Server> newServers = _serversList.where((server) => server.address != serverAddress).toList();
      _serversList = newServers;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setDefaultServer(Server server) async {
    final updated = await setDefaultServerDb(server.address);
    if (updated == true) {
      List<Server> newServers = _serversList.map((s) {
        if (s.address == server.address) {
          s.defaultServer = true;
          return s;
        }
        else {
          return s;
        }
      }).toList();
      _serversList = newServers;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
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

  Future<bool> saveToDb(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO servers (address, alias, token, isDefaultServer) VALUES ("${server.address}", "${server.alias}", "${server.token}", 0)',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  FutureOr<Map<String, dynamic>> checkUrlExists(String url) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        final result = await txn.rawQuery(
          'SELECT count(address) as quantity FROM servers WHERE address = "$url"',
        );
        if (result[0]['quantity'] == 0) {
          return {
            'result': 'success',
            'exists': false
          };
        }
        else {
          return {
            'result': 'success',
            'exists': true
          };
        }
      });
    } catch (e) {
      return {
        'result': 'fail'
      };
    }
  }

  Future<bool> setDefaultServerDb(String url) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE servers SET isDefaultServer = 0 WHERE isDefaultServer = 1',
        );
        await txn.rawUpdate(
          'UPDATE servers SET isDefaultServer = 1 WHERE address = "$url"',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromDb(String address) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM servers WHERE address = "$address"',
        );
        return true;
      });
    } catch (e) {
      return false;
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

  Future<bool> deleteDbData() async {
    _serversList = [];
    _connectedServer = null;
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM servers',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }
}