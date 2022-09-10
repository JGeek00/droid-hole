import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:sqflite/sqlite_api.dart';

class AppConfigProvider with ChangeNotifier {
  int _selectedTab = 0;
  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;
  PackageInfo? _appInfo;
  int? _autoRefreshTime = 2;
  int _selectedTheme = 0;
  int _overrideSslCheck = 0;
  int _oneColumnLegend = 0;
  int _reducedDataCharts = 0;
  double _logsPerQuery = 2;
  String? _passCode;
  bool _biometricsSupport = false;
  int _useBiometrics = 0;
  bool _appUnlocked = true;
  bool _validVibrator = false;
  int _importantInfoReaden = 0;
  int _hideZeroValues = 0;

  Database? _dbInstance;

  int get selectedTab {
    return _selectedTab;
  }

  PackageInfo? get getAppInfo {
    return _appInfo;
  }

  int? get getAutoRefreshTime {
    return _autoRefreshTime;
  }

  ThemeMode get selectedTheme {
    switch (_selectedTheme) {
      case 0:
        return SchedulerBinding.instance.window.platformBrightness == Brightness.light 
          ? ThemeMode.light 
          : ThemeMode.dark;

      case 1:
        return ThemeMode.light;

      case 2:
        return ThemeMode.dark;

      default:
        return ThemeMode.light;
    }
  }

  Database? get dbInstance {
    return _dbInstance;
  }

  int get selectedThemeNumber {
    return _selectedTheme;
  }

  bool get overrideSslCheck {
    return _overrideSslCheck == 0 ? false : true;
  }

  bool get oneColumnLegend {
    return _oneColumnLegend == 0 ? false : true;
  }

  bool get reducedDataCharts {
    return _reducedDataCharts == 0 ? false : true;
  }

  double get logsPerQuery {
    return _logsPerQuery;
  }

  AndroidDeviceInfo? get androidDeviceInfo {
    return _androidDeviceInfo;
  }

  IosDeviceInfo? get iosDeviceInfo {
    return _iosDeviceInfo;
  }

  String? get passCode {
    return _passCode;
  }

  bool get biometricsSupport {
    return _biometricsSupport;
  }

  bool get useBiometrics {
    return _useBiometrics == 0 ? false : true;
  }
  
  bool get appUnlocked {
    return _appUnlocked;
  }

  bool get validVibrator {
    return _validVibrator;
  }

  bool get importantInfoReaden {
    return _importantInfoReaden == 0 ? false : true;
  }

  bool get hideZeroValues {
    return _hideZeroValues == 0 ? false : true;
  }

  void setSelectedTab(int selectedTab) {
    _selectedTab = selectedTab;
    notifyListeners();
  }

  void setAppInfo(PackageInfo appInfo) {
    _appInfo = appInfo;
    notifyListeners();
  }

  void setAndroidInfo(AndroidDeviceInfo deviceInfo) {
    _androidDeviceInfo = deviceInfo;
    notifyListeners();
  }

  void setIosInfo(IosDeviceInfo deviceInfo) {
    _iosDeviceInfo = deviceInfo;
    notifyListeners();
  }

  void setBiometricsSupport(bool isSupported) {
    _biometricsSupport = isSupported;
    notifyListeners();
  }

  void setAppUnlocked(bool status) {
    _appUnlocked = status;
    notifyListeners();
  }

  void setValidVibrator(bool valid) {
    _validVibrator = valid;
    notifyListeners();
  }

  Future<bool> setUseBiometrics(bool biometrics) async {
    final updated = await _updateUseBiometricAuthDb(biometrics == true ? 1 : 0);
    if (updated == true) {
      _useBiometrics = biometrics == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setImportantInfoReaden(bool status) async {
    final updated = await _updateImportantInfoReadenDb(status == true ? 1 : 0);
    if (updated == true) {
      _importantInfoReaden = status == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setPassCode(String? code) async {
    if (_useBiometrics == 1) {
      final updated = await _updateUseBiometricAuthDb(0);
      if (updated == true) {
        _useBiometrics = 0;
        final updated2 = await updatePassCodeDb(code);
        if (updated2 == true) {
          _passCode = code;
          notifyListeners();
          return true;
        }
        else {
          return false;
        }
      }
      else {
        return false;
      }
    }
    else {
      final updated = await updatePassCodeDb(code);
      if (updated == true) {
        _passCode = code;
        notifyListeners();
        return true;
      }
      else {
        return false;
      }
    }
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

  Future<bool> setLogsPerQuery(double time) async {
    final updated = await updateLogsPerQueryDb(time);
    if (updated == true) {
      _logsPerQuery = time;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  void saveFromDb(Database dbInstance, Map<String, dynamic> dbData) {
    _autoRefreshTime = dbData['autoRefreshTime'];
    _selectedTheme = dbData['theme'];
    _overrideSslCheck = dbData['overrideSslCheck'];
    _oneColumnLegend = dbData['oneColumnLegend'];
    _reducedDataCharts = dbData['reducedDataCharts'];
    _logsPerQuery = dbData['logsPerQuery'].toDouble();
    _passCode = dbData['passCode'];
    _useBiometrics = dbData['useBiometricAuth'];
    _importantInfoReaden = dbData['importantInfoReaden'];
    _hideZeroValues = dbData['hideZeroValues'];
    _dbInstance = dbInstance;

    if (dbData['passCode'] != null) {
      _appUnlocked = false;
    }

    notifyListeners();
  }

  Future<bool> setOverrideSslCheck(bool status) async {
    final updated = await _updateOverrideSslCheck(status == true ? 1 : 0);
    if (updated == true) {
      _overrideSslCheck = status == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setOneColumnLegend(bool status) async {
    final updated = await _updateOneColumnLegend(status == true ? 1 : 0);
    if (updated == true) {
      _oneColumnLegend = status == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setReducedDataCharts(bool status) async {
    final updated = await _updateReducedDataCharts(status == true ? 1 : 0);
    if (updated == true) {
      _reducedDataCharts = status == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setHideZeroValues(bool status) async {
    final updated = await _updateHideZeroValuesDb(status == true ? 1 : 0);
    if (updated == true) {
      _hideZeroValues = status == true ? 1 : 0;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setSelectedTheme(int value) async {
    final updated = await _updateThemeDb(value);
    if (updated == true) {
      _selectedTheme = value;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
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

  Future<bool> updatePassCodeDb(String? value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET passCode = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLogsPerQueryDb(double value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET logsPerQuery = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateThemeDb(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET theme = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateOverrideSslCheck(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET overrideSslCheck = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateOneColumnLegend(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET oneColumnLegend = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateReducedDataCharts(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET reducedDataCharts = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateHideZeroValuesDb(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET hideZeroValues = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateUseBiometricAuthDb(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET useBiometricAuth = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateImportantInfoReadenDb(int value) async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET importantInfoReaden = $value',
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreAppConfig() async {
    try {
      return await _dbInstance!.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE appConfig SET autoRefreshTime = 5, theme = 0, overrideSslCheck = 0, oneColumnLegend = 0, reducedDataCharts = 0, logsPerQuery = 2, passCode = null, useBiometricAuth = 0',
        );
        _autoRefreshTime = 5;
        _selectedTheme = 0;
        _overrideSslCheck = 0;
        _oneColumnLegend = 0;
        _reducedDataCharts = 0;
        _logsPerQuery = 2;
        _passCode = null;
        _useBiometrics = 0;
        _importantInfoReaden = 0;
        _hideZeroValues = 0;
        return true;
      });
    } catch (e) {
      return false;
    }
  }
}