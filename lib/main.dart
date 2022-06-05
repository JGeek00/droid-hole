import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/connected_server_provider.dart';

import 'package:droid_hole/screens/base.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServersProvider serversProvider = ServersProvider();
  ConnectedServerProvider connectedServerProvider = ConnectedServerProvider();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => connectedServerProvider)
        ),
        ChangeNotifierProxyProvider<ConnectedServerProvider, ServersProvider>(
          create: ((context) => serversProvider), 
          update: (context, connectedServerProvider, serversProvider) => serversProvider!..update(connectedServerProvider),
        )
      ],
      child: const DroidHole(),
    )
  );
}

class DroidHole extends StatefulWidget {
  const DroidHole({Key? key}) : super(key: key);

  @override
  State<DroidHole> createState() => _DroidHoleState();
}

class _DroidHoleState extends State<DroidHole> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droid Hole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Base()
    );
  }
}
