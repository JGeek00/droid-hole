// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/server.dart';

class DeleteModal extends StatelessWidget {
  final Server serverToDelete;

  const DeleteModal({
    Key? key,
    required this.serverToDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    void _removeServer() async {
      final deleted = await serversProvider.removeServer(serverToDelete.address);
      Navigator.pop(context);
      if (deleted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionRemoved),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionCannotBeRemoved),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(Icons.delete),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppLocalizations.of(context)!.remove,
                  style: const TextStyle(
                    fontSize: 24
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.removeWarning
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
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 20,
                  bottom: 10
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => {
                            Navigator.pop(context)
                          }, 
                          child: Text(AppLocalizations.of(context)!.cancel)
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: _removeServer,
                          child: Text(AppLocalizations.of(context)!.remove),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}