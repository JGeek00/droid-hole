import 'package:flutter/material.dart';

class SettingsTopBar extends StatelessWidget {
  const SettingsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      margin: EdgeInsets.only(top: statusBarHeight),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/icon-no-background.png',
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