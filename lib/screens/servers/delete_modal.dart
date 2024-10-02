// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/models/server.dart';

class DeleteModal extends StatelessWidget {
  final Server serverToDelete;

  const DeleteModal({
    super.key,
    required this.serverToDelete,
  });

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void removeServer() async {
      final deleted = await serversProvider.removeServer(serverToDelete.address);
      Navigator.pop(context);
      if (deleted == true) {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.connectionRemoved,
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.connectionCannotBeRemoved,
          color: Colors.red
        );
      }
    }

    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.delete,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.remove,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                AppLocalizations.of(context)!.removeWarning,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  serverToDelete.address,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => {
            Navigator.pop(context)
          }, 
          child: Text(AppLocalizations.of(context)!.cancel)
        ),
        TextButton(
          onPressed: removeServer,
          child: Text(AppLocalizations.of(context)!.remove),
        ),
      ],
    );
  }
}