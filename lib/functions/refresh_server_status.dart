// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

Future refreshServerStatus(BuildContext context, ServersProvider serversProvider) async {
  final result = await realtimeStatus(
    serversProvider.selectedServer!,
    serversProvider.selectedServerToken!['phpSessId']
  );
  if (result['result'] == "success") {
    serversProvider.updateselectedServerStatus(
      result['data'].status == 'enabled' ? true : false
    );
    serversProvider.setIsServerConnected(true);
    serversProvider.setRealtimeStatus(result['data']);
  }
  else {
    serversProvider.setIsServerConnected(false);
    if (serversProvider.getStatusLoading == 0) {
      serversProvider.setStatusLoading(2);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.couldNotConnectServer),
        backgroundColor: Colors.red,
      )
    );
  }
}