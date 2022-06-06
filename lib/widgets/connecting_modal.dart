import 'package:flutter/material.dart';

class ConnectingModal extends StatelessWidget {
  const ConnectingModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 30),
            Text("Connecting...")
          ],
        ),
      ),
    );
  }
}