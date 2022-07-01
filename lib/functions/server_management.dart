// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';

void enableServer(BuildContext context) async {
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);

  final ProcessModal process = ProcessModal(context: context);
  process.open(AppLocalizations.of(context)!.enablingServer);
  final result = await enableServerRequest(
    serversProvider.selectedServer!,
    serversProvider.selectedServerToken!['token'],
    serversProvider.selectedServerToken!['phpSessId']
  );
  process.close();
  if (result['result'] == 'success') {
    serversProvider.updateselectedServerStatus(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.serverEnabled),
        backgroundColor: Colors.green,
      )
    );
  }
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.couldntEnableServer),
        backgroundColor: Colors.red,
      )
    );
  }
}

void disableServer(int time, BuildContext context) async {
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);

  final ProcessModal process = ProcessModal(context: context);
  process.open(AppLocalizations.of(context)!.disablingServer);
  final result = await disableServerRequest(
    serversProvider.selectedServer!, 
    serversProvider.selectedServerToken!['token'],
    serversProvider.selectedServerToken!['phpSessId'],
    time
  );
  process.close();
  if (result['result'] == 'success') {
    serversProvider.updateselectedServerStatus(false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.serverDisabled),
        backgroundColor: Colors.green,
      )
    );
  }
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.couldntDisableServer),
        backgroundColor: Colors.red,
      )
    );
  }
}