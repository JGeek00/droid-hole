import 'package:droid_hole/providers/servers_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/enable_disable_modal.dart';

void openModalBottomSheet(BuildContext context, String sheet) {
  final serversProvider = Provider.of<ServersProvider>(context, listen: false);

  showModalBottomSheet(
    context: context, 
    isScrollControlled: true,
    builder: (context) {
      switch (sheet) {
        case 'enableDisable':
          return EnableDisableModal(
            onCancel: () => {Navigator.pop(context)},
            onConfirm: (time) => {},
          );
          
        case 'addServer':
          return AddServerModal(
            onCancel: () => {Navigator.pop(context)},
            onConfirm: (server) {
              serversProvider.addServer(server);
              Navigator.pop(context);
            },
          );
          
        default:
          return const SizedBox();
      }
    },
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
  );
}