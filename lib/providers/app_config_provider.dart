import 'package:droid_hole/models/app_log.dart';
import 'package:droid_hole/services/database/queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqlite_api.dart';

class AppConfigProvider with ChangeNotifier {
  bool _showingSnackbar = false;
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
  int _statisticsVisualizationMode = 0;
  int? _selectedSettingsScreen;

  final List<AppLog> _logs = [];

  Database? _dbInstance;

  bool get showingSnackbar {
    return _showingSnackbar;
  }

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

  int get statisticsVisualizationMode {
    return _statisticsVisualizationMode;
  }

  List<AppLog> get logs {
    return _logs;
  }

  int? get selectedSettingsScreen {
    return _selectedSettingsScreen;
  }

  void setShowingSnackbar(bool status) {
    _showingSnackbar = status;
    notifyListeners();
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

  void addLog(AppLog log) {
    _logs.add(log);
    notifyListeners();
  }

  void setSelectedSettingsScreen({required int? screen, bool? notify}) {
    _selectedSettingsScreen = screen;
    if (notify == true) {
      notifyListeners();
    }
  }

  Future<bool> setUseBiometrics(bool biometrics) async {
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'useBiometricAuth',
      value: biometrics == true ? 1 : 0
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'importantInfoReaden',
      value: status == true ? 1 : 0
    );
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
      final updated = await updateConfigQuery(
        db: _dbInstance!,
        column: 'useBiometricAuth',
        value: 0
      );
      if (updated == true) {
        _useBiometrics = 0;
        final updated2 = await updateConfigQuery(
          db: _dbInstance!,
          column: 'passCode',
          value: code
        );
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
      final updated = await updateConfigQuery(
        db: _dbInstance!,
        column: 'passCode',
        value: code
      );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'autoRefreshTime',
      value: seconds
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'logsPerQuery',
      value: time
    );
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
    _statisticsVisualizationMode = dbData['statisticsVisualizationMode'];
    _dbInstance = dbInstance;

    if (dbData['passCode'] != null) {
      _appUnlocked = false;
    }

    notifyListeners();
  }

  Future<bool> setOverrideSslCheck(bool status) async {
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'overrideSslCheck',
      value: status == true ? 1 : 0
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'oneColumnLegend',
      value: status == true ? 1 : 0
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'reducedDataCharts',
      value: status == true ? 1 : 0
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'hideZeroValues',
      value: status == true ? 1 : 0
    );
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
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'theme',
      value: value
    );
    if (updated == true) {
      _selectedTheme = value;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> setStatisticsVisualizationMode(int value) async {
    final updated = await updateConfigQuery(
      db: _dbInstance!,
      column: 'statisticsVisualizationMode',
      value: value
    );
    if (updated == true) {
      _statisticsVisualizationMode = value;
      notifyListeners();
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> restoreAppConfig() async {
    final result = await restoreAppConfigQuery(_dbInstance!);
    if (result == true) {
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
      _statisticsVisualizationMode = 0;

      notifyListeners();

      return true;
    }
    else {
      return false;
    }
  }
}