import 'package:flutter/material.dart';

import 'package:droid_hole/widgets/process_modal.dart';

void openProcessModal(BuildContext context, String message) async {
  await Future.delayed(const Duration(seconds: 0), () => {
    showDialog(
      context: context, 
      builder: (context) => ProcessModal(message: message),
      barrierDismissible: false,
      useSafeArea: true,
    )
  });
}

void closeProcessModal(BuildContext context) {
  Navigator.pop(context);
}