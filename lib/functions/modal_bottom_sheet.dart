import 'package:flutter/material.dart';

import 'package:droid_hole/widgets/enable_disable_modal.dart';

void openEnableDisableBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context, 
    isScrollControlled: true,
    builder: (context) => EnableDisableModal(
      onCancel: () => {Navigator.pop(context)},
      onConfirm: (time) => {},
    ),
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
  );
}