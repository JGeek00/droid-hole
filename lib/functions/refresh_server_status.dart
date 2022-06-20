import 'package:flutter/material.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

Future refreshServerStatus(BuildContext context, ServersProvider serversProvider) async {
  final result = await realtimeStatus(serversProvider.connectedServer!);
  if (result['result'] == "success") {
    serversProvider.updateConnectedServerStatus(
      result['data'].status == 'enabled' ? true : false
    );
    serversProvider.setIsServerConnected(true);
    serversProvider.setRealtimeStatus(result['data']);
  }
  else {
    serversProvider.setIsServerConnected(false);
    if (serversProvider.getStatusLoading == 0) {
      serversProvider.setStatusLoading(2);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Could not connect to the server."),
        backgroundColor: Colors.red,
      )
    );
  }
}