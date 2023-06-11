// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

Future refreshServerStatus(BuildContext context) async {
  final statusProvider = Provider.of<StatusProvider>(context, listen: false);
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);
  final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);

  final result = await realtimeStatus(
    serversProvider.selectedServer!
  );
  if (result['result'] == "success") {
    serversProvider.updateselectedServerStatus(
      result['data'].status == 'enabled' ? true : false
    );
    statusProvider.setIsServerConnected(true);
    statusProvider.setRealtimeStatus(result['data']);
  }
  else if (result['result'] == 'ssl_error') {
    statusProvider.setIsServerConnected(false);
    if (statusProvider.getStatusLoading == LoadStatus.loading) {
      statusProvider.setStatusLoading(LoadStatus.error);
    }
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.sslErrorShort, 
      color: Colors.red
    );
  }
  else {
    statusProvider.setIsServerConnected(false);
    if (statusProvider.getStatusLoading == LoadStatus.loading) {
      statusProvider.setStatusLoading(LoadStatus.error);
    }
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.couldNotConnectServer, 
      color: Colors.red
    );
  }
}