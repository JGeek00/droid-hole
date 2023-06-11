import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  List<Server> _serversList = [];
  Database? _dbInstance;

  Server? _selectedServer;

  List<Server> get getServersList {
    return _serversList;
  }

  Server? get selectedServer {
    return _selectedServer;
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

  Future<bool> editServer(Server server) async {
    final result = await editServerDb(server);
    if (result == true) {
      List<Server> newServers = _serversList.map((s) {
        if (s.address == server.address) {
          return server;
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

  Future<bool> removeServer(String serverAddress) async {
    final result = await removeFromDb(serverAddress);
    if (result == true) {
      _selectedServer = null;
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
          s.defaultServer = false;
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

  Future<bool> settoken(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'UPDATE servers SET token = "${server.token}" WHERE address = "${server.address}"',
        );
        _serversList = _serversList.map((s) {
          if (s.address == server.address) {
            return server;
          }
          else {
            return s;
          }
        }).toList();
        notifyListeners();
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future saveFromDb(List<Map<String, dynamic>>? servers, bool connect) async {
   if (servers != null) {
      Server? defaultServer;
      for (var server in servers) {
        final Server serverObj = Server(
          address: server['address'], 
          alias: server['alias'],
          token: server['token'],
          defaultServer: convertFromIntToBool(server['isDefaultServer'])!,
          basicAuthUser: server['basicAuthUser'],
          basicAuthPassword: server['basicAuthPassword']
        );
        _serversList.add(serverObj);
        if (convertFromIntToBool(server['isDefaultServer']) == true) {
          defaultServer = serverObj;
        }

        if (defaultServer != null) {
          _selectedServer = defaultServer;
        }

        notifyListeners();
      }
    }
    else {
      notifyListeners();
    }
  }

  Future<bool> login(Server serverObj) async {
    final result = await loginQuery(serverObj);
    if (result['result'] == 'success') {
      _selectedServer = serverObj;
      notifyListeners();
      return true;
    }
    else {
      _selectedServer = serverObj;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveToDb(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO servers (address, alias, token, isDefaultServer, basicAuthUser, basicAuthPassword) VALUES ("${server.address}", "${server.alias}", "${server.token}", 0, "${server.basicAuthUser}", "${server.basicAuthPassword}")',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> editServerDb(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE servers SET alias = "${server.alias}", token = "${server.token}", isDefaultServer = ${convertFromBoolToInt(server.defaultServer)}, basicAuthUser = "${server.basicAuthUser}", basicAuthPassword = "${server.basicAuthPassword}" WHERE address = "${server.address}"',
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

  void setselectedServer(Server? server) {
    _selectedServer = server;
    notifyListeners();
  }

  void updateselectedServerStatus(bool enabled) {
    if (_selectedServer != null) {
      _selectedServer!.enabled = enabled;
      notifyListeners();
    }
  }

  void setDbInstance(Database db) {
    _dbInstance = db;
  }

  Future<bool> deleteDbData() async {
    _serversList = [];
    _selectedServer = null;

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