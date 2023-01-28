import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/models/realtime_status.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  List<Server> _serversList = [];
  Database? _dbInstance;

  Server? _selectedServer;
  bool? _isServerConnected;
  String? _phpSessId;
  bool _refreshServerStatus = false;

  int _statusLoading = 0;
  RealtimeStatus? _realtimeStatus;

  int _overtimeDataLoading = 0;
  OverTimeData? _overtimeData;

  bool _startAutoRefresh = false;

  List<Server> get getServersList {
    return _serversList;
  }

  Server? get selectedServer {
    return _selectedServer;
  }

  String? get phpSessId {
    return _phpSessId;
  }

  bool? get isServerConnected {
    return _isServerConnected;
  }

  RealtimeStatus? get getRealtimeStatus {
    return _realtimeStatus;
  }

  int get getStatusLoading {
    return _statusLoading;
  }

  OverTimeData? get getOvertimeData {
    return _overtimeData;
  }

  Map<String, dynamic>? get getOvertimeDataJson {
    if (_overtimeData != null) {
      return _overtimeData!.toJson();
    }
    else {
      return null;
    }
  }

  int get getOvertimeDataLoadStatus {
    return _overtimeDataLoading;
  }

  bool get getRefreshServerStatus {
    return _refreshServerStatus;
  }
  
  bool get startAutoRefresh {
    return _startAutoRefresh;
  }

  void setStartAutoRefresh(bool value) {
    _startAutoRefresh = value;
  }

  void setRefreshServerStatus(bool status) {
    _refreshServerStatus = status;
    if (status == true) {
      notifyListeners();
    }
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

  void setStatusLoading(int status) {
    _statusLoading = status;
    notifyListeners();
  }

  void setRealtimeStatus(RealtimeStatus realtimeStatus) {
    _realtimeStatus = realtimeStatus;
    _statusLoading = 1;
    notifyListeners();
  }

  void setPhpSessId(String value) {
    _phpSessId = value;
    notifyListeners();
  }

  void setIsServerConnected(bool status) {
    _isServerConnected = status;
    notifyListeners();
  }

  void setOvertimeDataLoadingStatus(int status) {
    _overtimeDataLoading = status;
    notifyListeners();
  }

  void setOvertimeData(OverTimeData value) {
    _overtimeData = value;
    notifyListeners();
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
      for (var server in servers) {
        final Server serverObj = Server(
          address: server['address'], 
          alias: server['alias'],
          token: server['token'],
          defaultServer: convertFromIntToBool(server['isDefaultServer'])!,
        );
        _serversList.add(serverObj);
        if (convertFromIntToBool(server['isDefaultServer']) == true) {
          _selectedServer = serverObj;
          if (connect == true) {
            fetchMainData(serverObj);
          }
          else {
            _isServerConnected = null;
          }
        }
      }
    }
    notifyListeners();
  }

  void fetchMainData(Server server) async {
    final result = await Future.wait([
      realtimeStatus(server),
      fetchOverTimeData(server)
    ]);

    if (result[0]['result'] == 'success' && result[1]['result'] == 'success') {
      _realtimeStatus = result[0]['data'];
      _overtimeData = result[1]['data'];
      _selectedServer?.enabled = result[0]['data'].status == 'enabled' ? true : false;

      _overtimeDataLoading = 1;
      _statusLoading = 1;

      _startAutoRefresh = true;
      _isServerConnected = true;
    }
    else {
      _overtimeDataLoading = 2;
      _statusLoading = 2;

      _isServerConnected = false;
    }
  }

  Future<bool> login(Server serverObj) async {
    final result = await loginQuery(serverObj);
    if (result['result'] == 'success') {
      _selectedServer = serverObj;
      _realtimeStatus = result['realtimeStatus'];
      _phpSessId = result['phpSessId'];
      _isServerConnected = true;
      _statusLoading = 1;
      notifyListeners();
      return true;
    }
    else {
      _isServerConnected = false;
      _selectedServer = serverObj;
      _statusLoading = 2;
      notifyListeners();
      return false;
    }
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

  Future<bool> editServerDb(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE servers SET alias = "${server.alias}", token = "${server.token}", isDefaultServer = ${convertFromBoolToInt(server.defaultServer)} WHERE address = "${server.address}"',
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
    if (server != null) {
      _isServerConnected = true;
    }
    else {
      _isServerConnected = false;
    }
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
    _isServerConnected = false;
    _selectedServer = null;
    _phpSessId = null;
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