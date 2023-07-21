import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/models/realtime_status.dart';
import 'package:flutter/material.dart';

class StatusProvider with ChangeNotifier {
  bool _isServerConnected = false;

  bool _refreshServerStatus = false;

  LoadStatus _statusLoading = LoadStatus.loading;
  RealtimeStatus? _realtimeStatus;

  int _overtimeDataLoading = 0;
  OverTimeData? _overtimeData;

  bool _startAutoRefresh = false;

  bool get isServerConnected {
    return _isServerConnected;
  }

  RealtimeStatus? get getRealtimeStatus {
    return _realtimeStatus;
  }

  LoadStatus get getStatusLoading {
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

  void setIsServerConnected(bool value) {
    _isServerConnected = value;
    notifyListeners();
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

    void setStatusLoading(LoadStatus status) {
    _statusLoading = status;
    notifyListeners();
  }

  void setRealtimeStatus(RealtimeStatus realtimeStatus) {
    _realtimeStatus = realtimeStatus;
    _statusLoading = LoadStatus.loaded;
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
}