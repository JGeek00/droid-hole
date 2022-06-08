import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfigProvider with ChangeNotifier {
  PackageInfo? _appInfo;

  PackageInfo? get getAppInfo {
    return _appInfo;
  }

  void setAppInfo(PackageInfo appInfo) {
    _appInfo = appInfo;
    notifyListeners();
  }
}