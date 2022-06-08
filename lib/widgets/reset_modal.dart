import 'package:flutter/material.dart';

class ResetModal extends StatelessWidget {
  final void Function() onConfirm;

  const ResetModal({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 205,
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 10
        ),
        child: Column(
          children: [
            const Text(
              "Reset application data",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Warning! This action will reset the application and remove all it's data.\n\nAre you sure you want to continue?"
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => {Navigator.pop(context)}, 
                  child: const Text("Cancel"),
                ), 
                TextButton.icon(
                  onPressed: onConfirm, 
                  icon: const Icon(Icons.delete), 
                  label: const Text("Delete"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1)),
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