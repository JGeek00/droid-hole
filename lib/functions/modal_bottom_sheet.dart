import 'package:flutter/material.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/enable_disable_modal.dart';

void openModalBottomSheet(BuildContext context, String sheet) {
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
          return const AddServerModal();
          
        default:
          return const SizedBox();
      }
    },
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
  );
}