// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';

void enableServer(BuildContext context) async {
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);
  final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);

  final ProcessModal process = ProcessModal(context: context);
  process.open(AppLocalizations.of(context)!.enablingServer);
  final result = await enableServerRequest(
    serversProvider.selectedServer!
  );
  process.close();
  if (result['result'] == 'success') {
    serversProvider.updateselectedServerStatus(true);
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.serverEnabled, 
      color: Colors.green
    );
  }
  else {
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.couldntEnableServer, 
      color: Colors.red
    );
  }
}

void disableServer(int time, BuildContext context) async {
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);
  final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);

  final ProcessModal process = ProcessModal(context: context);
  process.open(AppLocalizations.of(context)!.disablingServer);
  final result = await disableServerRequest(
    serversProvider.selectedServer!,
    time
  );
  process.close();
  if (result['result'] == 'success') {
    serversProvider.updateselectedServerStatus(false);
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.serverDisabled, 
      color: Colors.green
    );
  }
  else {
    showSnackBar(
      context: context, 
      appConfigProvider: appConfigProvider,
      label: AppLocalizations.of(context)!.couldntDisableServer, 
      color: Colors.red
    );
  }
}