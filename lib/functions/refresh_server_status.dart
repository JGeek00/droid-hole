// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

Future refreshServerStatus(BuildContext context, ServersProvider serversProvider, AppConfigProvider appConfigProvider) async {
  final result = await realtimeStatus(
    serversProvider.selectedServer!
  );
  if (result['result'] == "success") {
    serversProvider.updateselectedServerStatus(
      result['data'].status == 'enabled' ? true : false
    );
    serversProvider.setIsServerConnected(true);
    serversProvider.setRealtimeStatus(result['data']);
  }
  else if (result['result'] == 'ssl_error') {
    serversProvider.setIsServerConnected(false);
    if (serversProvider.getStatusLoading == LoadStatus.loading) {
      serversProvider.setStatusLoading(LoadStatus.error);
    }
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.sslErrorShort, 
      color: Colors.red
    );
  }
  else {
    serversProvider.setIsServerConnected(false);
    if (serversProvider.getStatusLoading == LoadStatus.loading) {
      serversProvider.setStatusLoading(LoadStatus.error);
    }
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.couldNotConnectServer, 
      color: Colors.red
    );
  }
}