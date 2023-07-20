import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/services/database/queries.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  AppConfigProvider? _appConfigProvider;

  update(AppConfigProvider? provider) {
    _appConfigProvider = provider;
  }

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
    final saved = await saveServerQuery(_dbInstance!, server);
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
    final result = await editServerQuery(_dbInstance!, server);
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
    final result = await removeServerQuery(_dbInstance!, serverAddress);
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
    final updated = await setDefaultServerQuery(_dbInstance!, server.address);
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

  Future<bool> setToken(Server server) async {
    final result = await setServerTokenQuery(_dbInstance!, server.token, server.address);
    if (result == true) {
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
    }
    else {
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

  FutureOr<Map<String, dynamic>> checkUrlExists(String url) async {
    return await checkUrlExistsQuery(_dbInstance!, url);
  }

  void setselectedServer({
    required Server? server, 
    bool? toHomeTab
  }) {
    _selectedServer = server;
    if (toHomeTab == true) _appConfigProvider!.setSelectedTab(0);
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
    final result = await deleteServersDataQuery(_dbInstance!);
    if (result == true) {
      _serversList = [];
      _selectedServer = null;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }
}