import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqlite_api.dart';

class AppConfigProvider with ChangeNotifier {
  PackageInfo? _appInfo;
  int? _autoRefreshTime = 2;

  Database? _dbInstance;

  PackageInfo? get getAppInfo {
    return _appInfo;
  }

  int? get getAutoRefreshTime {
    return _autoRefreshTime;
  }

  void setAppInfo(PackageInfo appInfo) {
    _appInfo = appInfo;
    notifyListeners();
  }

  Future<bool> setAutoRefreshTime(int seconds) async {
    final updated = await updateAutoRefreshTimeDb(seconds);
    if (updated == true) {
      _autoRefreshTime = seconds;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  void saveFromDb(Database dbInstance, Map<String, dynamic> dbData) {
    _autoRefreshTime = dbData['autoRefreshTime'];
    _dbInstance = dbInstance;
    notifyListeners();
  }

  Future<bool> updateAutoRefreshTimeDb(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET autoRefreshTime = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }
}