import 'package:flutter/material.dart';

class SettingsTopBar extends StatelessWidget {
  const SettingsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/icon512.png',
            width: 100,
          ),
          const SizedBox(width: 40),
          const Text(
            "DroidHole",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          )
        ],
      ),
    );
  }
}