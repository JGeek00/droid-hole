import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      if (deleted == true) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection removed successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection cannot be removed."),
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
        child: Column(
          children: [
            const Text(
              "Remove",
              style: TextStyle(
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
                  const Text(
                    "Are you sure you want to remove this PiHole server?"
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => {
                    Navigator.pop(context)
                  }, 
                  icon: const Icon(Icons.cancel), 
                  label: const Text("Cancel")
                ),
                TextButton.icon(
                  onPressed: _removeServer, 
                  icon: const Icon(Icons.delete), 
                  label: const Text("Remove"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1))
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}