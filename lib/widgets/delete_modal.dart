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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: Platform.isIOS ? 7 : 10
        ),
        height: 200,
        width: 400,
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.remove,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => {
                          Navigator.pop(context)
                        }, 
                        icon: const Icon(Icons.cancel), 
                        label: Text(AppLocalizations.of(context)!.cancel)
                      ),
                      TextButton.icon(
                        onPressed: _removeServer, 
                        icon: const Icon(Icons.delete), 
                        label: Text(AppLocalizations.of(context)!.remove),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.red),
                          overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1))
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}