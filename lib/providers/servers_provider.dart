import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/models/realtime_status.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';

class ServersProvider with ChangeNotifier {
  List<Server> _serversList = [];
  Database? _dbInstance;

  Server? _selectedServer;
  bool? _isServerConnected;
  Map<String, dynamic> _selectedServerToken = {
    'formToken': '',
    'phpSessId': ''
  };
  bool _refreshServerStatus = false;

  int _statusLoading = 0;
  RealtimeStatus? _realtimeStatus;

  int _overtimeDataLoading = 0;
  OverTimeData? _overtimeData;

  List<Server> get getServersList {
    return _serversList;
  }

  Server? get selectedServer {
    return _selectedServer;
  }

  Map<String, dynamic>? get selectedServerToken {
    return _selectedServerToken;
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

  void setselectedServerToken(String token, String value) {
    _selectedServerToken[token] = value;
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

  Future<bool> setPwHash(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'UPDATE servers SET pwHash = "${server.pwHash}" WHERE address = "${server.address}"',
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

  Future saveFromDb(List<Map<String, dynamic>>? servers) async {
    if (servers != null) {
      for (var server in servers) {
        final Server serverObj = Server(
          address: server['address'], 
          alias: server['alias'],
          password: server['password'], 
          pwHash: server['pwHash'],
          defaultServer: convertFromIntToBool(server['isDefaultServer'])!,
        );
        _serversList.add(serverObj);
        if (convertFromIntToBool(server['isDefaultServer']) == true) {
          final result = await login(serverObj);
          if (result['result'] == 'success') {
            serverObj.enabled = result['status'] == 'enabled' ? true : false;
            _selectedServerToken['phpSessId'] = result['phpSessId'];
            _selectedServerToken['token'] = result['token'];
            _isServerConnected = true;
            _selectedServer = serverObj;
          }
          else {
            _isServerConnected = false;
            _selectedServer = serverObj;
          }
        }
      }
    }
    notifyListeners();
  }

  Future<bool> saveToDb(Server server) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO servers (address, alias, password, pwHash, isDefaultServer) VALUES ("${server.address}", "${server.alias}", "${server.password}", "${server.pwHash}", 0)',
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
          'UPDATE servers SET alias = "${server.alias}", password = "${server.password}", pwHash = "${server.pwHash}", isDefaultServer = ${convertFromBoolToInt(server.defaultServer)} WHERE address = "${server.address}"',
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

  void setselectedServer(Server server) {
    _selectedServer = server;
    _isServerConnected = true;
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
    _selectedServerToken = {
      'formToken': '',
      'phpSessId': ''
    };
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