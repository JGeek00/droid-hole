import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfigProvider with ChangeNotifier {
  PackageInfo? _appInfo;
  int? _autoRefreshTime = 10;

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

  void setAutoRefreshTime(int seconds) {
    _autoRefreshTime = seconds;
    notifyListeners();
  }
}