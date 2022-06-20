import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class SelectedServerDisconnected extends StatelessWidget {
  const SelectedServerDisconnected({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final height = MediaQuery.of(context).size.height;

    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: height-180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Selected server is disconnected",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () => refreshServerStatus(context, serversProvider),
                  icon: const Icon(Icons.refresh), 
                  label: const Text("Try reconnect")
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}