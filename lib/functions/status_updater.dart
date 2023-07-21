import 'dart:async';

import 'package:droid_hole/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

class StatusUpdater {
  BuildContext? context;
  Timer? _statusDataTimer;
  Timer? _overTimeDataTimer;

  int? _previousRefreshTime;
  void _updateStatusData(ServersProvider serversProvider, StatusProvider statusProvider, AppConfigProvider appConfigProvider) {
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
        _updateStatusData(serversProvider, statusProvider, appConfigProvider);
      }

      if (isRunning == false) {
        isRunning = true;
        if (serversProvider.selectedServer != null) {
          String selectedUrlBefore = serversProvider.selectedServer!.address;
          final statusResult = await realtimeStatus(
            serversProvider.selectedServer!
          );
          if (statusResult['result'] == 'success') {
            serversProvider.updateselectedServerStatus(
              statusResult['data'].status == 'enabled' ? true : false
            );
            statusProvider.setRealtimeStatus(statusResult['data']);
            if (statusProvider.isServerConnected == false) {
              statusProvider.setIsServerConnected(true);
            }
          }
          else {
            if (selectedUrlBefore == serversProvider.selectedServer!.address) {
              if (statusProvider.isServerConnected == true) {
                statusProvider.setIsServerConnected(false);
              }
              if (statusProvider.getStatusLoading == LoadStatus.loading) {
                statusProvider.setStatusLoading(LoadStatus.error);
              }
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

  void _updateOverTimeData(ServersProvider serversProvider, StatusProvider statusProvider, FiltersProvider filtersProvider) {
    void timerFn({Timer? timer}) async {
      if (serversProvider.selectedServer != null) {
        String statusUrlBefore = serversProvider.selectedServer!.address;
        final statusResult = await fetchOverTimeData(
          serversProvider.selectedServer!
        );
        if (statusResult['result'] == 'success') {
          statusProvider.setOvertimeData(statusResult['data']);
          List<dynamic> clients = statusResult['data'].clients.map((client) {
            if (client.name != '') {
              return client.name.toString();
            }
            else {
              return client.ip.toString();
            }
          }).toList();
          filtersProvider.setClients(List<String>.from(clients));
          statusProvider.setOvertimeDataLoadingStatus(1);
          if (statusProvider.isServerConnected == false) {
            statusProvider.setIsServerConnected(true);
          }
        }
        else {
          if (statusUrlBefore == serversProvider.selectedServer!.address) {
            if (statusProvider.isServerConnected == true) {
              statusProvider.setIsServerConnected(false);
            }
            if (statusProvider.getOvertimeDataLoadStatus == 0) {
              statusProvider.setOvertimeDataLoadingStatus(2);
            }
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

  void statusData() {
    final serversProvider = Provider.of<ServersProvider>(context!);
    final statusProvider = Provider.of<StatusProvider>(context!);
    final appConfigProvider = Provider.of<AppConfigProvider>(context!);

    if (statusProvider.isServerConnected == true && _statusDataTimer == null) {
      _updateStatusData(serversProvider, statusProvider, appConfigProvider);
    }
    else if (statusProvider.isServerConnected == true && _statusDataTimer != null && _statusDataTimer!.isActive == false) {
      _updateStatusData(serversProvider, statusProvider, appConfigProvider);
    }
    else if (statusProvider.isServerConnected == false && _statusDataTimer != null) {
      _statusDataTimer!.cancel();
    }
  }

  void overTimeData() {
    final serversProvider = Provider.of<ServersProvider>(context!);
    final statusProvider = Provider.of<StatusProvider>(context!);
    final filtersProvider = Provider.of<FiltersProvider>(context!);

    if (statusProvider.isServerConnected == true && _overTimeDataTimer == null) {
      _updateOverTimeData(serversProvider, statusProvider, filtersProvider);
    }
    else if (statusProvider.isServerConnected == true && _overTimeDataTimer != null && _overTimeDataTimer!.isActive == false) {
      _updateOverTimeData(serversProvider, statusProvider, filtersProvider);
    }
    else if (statusProvider.isServerConnected == false && _overTimeDataTimer != null) {
      _overTimeDataTimer!.cancel();
    }
  }

  void cancelTimers() {
    if (_statusDataTimer != null) {
      _statusDataTimer!.cancel();
    }

    if (_overTimeDataTimer != null) {
      _overTimeDataTimer!.cancel();
    }
  }
}