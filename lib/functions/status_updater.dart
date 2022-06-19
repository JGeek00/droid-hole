import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

class StatusUpdater {
  Timer? _statusDataTimer;
  Timer? _overTimeDataTimer;

  int? _previousRefreshTime;
  void _updateStatusData(ServersProvider serversProvider, AppConfigProvider appConfigProvider) {
    // Sets previousRefreshTime when is not initialized
    _previousRefreshTime ??= appConfigProvider.getAutoRefreshTime;

    bool isRunning = false; // Prevents async request from being executed when last one is not completed yet
    void timerFn({Timer? timer}) async {
      // Restarts the statusDataTimer when time changes
      if (appConfigProvider.getAutoRefreshTime != _previousRefreshTime) {
        timer != null 
            ? _statusDataTimer!.cancel()
            : timer!.cancel();
        _previousRefreshTime = appConfigProvider.getAutoRefreshTime;
        _updateStatusData(serversProvider, appConfigProvider);
      }

      if (isRunning == false) {
        isRunning = true;
        if (serversProvider.connectedServer != null) {
          final statusResult = await realtimeStatus(serversProvider.connectedServer!);
          if (statusResult['result'] == 'success') {
            serversProvider.updateConnectedServerStatus(
              statusResult['data'].status == 'enabled' ? true : false
            );
            serversProvider.setRealtimeStatus(statusResult['data']);
          }
          else {
            serversProvider.setIsServerConnected(false);
            if (serversProvider.getStatusLoading == 0) {
              serversProvider.setStatusLoading(2);
            }
          }
          isRunning = false;
        }
        else {
          timer != null 
            ? _statusDataTimer!.cancel()
            : timer!.cancel();
        }
      }
    }
    _statusDataTimer = Timer.periodic(Duration(seconds: appConfigProvider.getAutoRefreshTime!), (timer) => timerFn(timer: timer));
    timerFn();
  }

  void _updateOverTimeData(ServersProvider serversProvider) {
    void timerFn({Timer? timer}) async {
      if (serversProvider.connectedServer != null) {
        final statusResult = await fetchOverTimeData(serversProvider.connectedServer!);
        if (statusResult['result'] == 'success') {
          serversProvider.setOvertimeData(statusResult['data']);
          serversProvider.setOvertimeDataLoadingStatus(1);
        }
        else {
          serversProvider.setIsServerConnected(false);
          if (serversProvider.getOvertimeDataLoadStatus == 0) {
            serversProvider.setOvertimeDataLoadingStatus(2);
          }
        }
      }
      else {
        timer != null 
            ? _overTimeDataTimer!.cancel()
            : timer!.cancel();
      }
    }
    _overTimeDataTimer = Timer.periodic(const Duration(minutes: 1), (timer) => timerFn(timer: timer));
    timerFn();
  }

  void statusData(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    if (serversProvider.isServerConnected == true && _statusDataTimer == null) {
      _updateStatusData(serversProvider, appConfigProvider);
    }
    else if (serversProvider.isServerConnected == true && _statusDataTimer != null && _statusDataTimer!.isActive == false) {
      _updateStatusData(serversProvider, appConfigProvider);
    }
    else if (serversProvider.isServerConnected == false && _statusDataTimer != null) {
      _statusDataTimer!.cancel();
    }
  }

  void overTimeData(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    if (serversProvider.isServerConnected == true && _overTimeDataTimer == null) {
      _updateOverTimeData(serversProvider);
    }
    else if (serversProvider.isServerConnected == true && _overTimeDataTimer != null && _overTimeDataTimer!.isActive == false) {
      _updateOverTimeData(serversProvider);
    }
    else if (serversProvider.isServerConnected == false && _overTimeDataTimer != null) {
      _overTimeDataTimer!.cancel();
    }
  }
}