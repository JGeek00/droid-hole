import 'package:flutter/material.dart';

class ProcessModal extends StatelessWidget {
  final String message;

  const ProcessModal({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 30
        ),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 40),
            Text(message)
          ],
        ),
      ),
    );
  }
}