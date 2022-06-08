import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

import 'package:droid_hole/screens/base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServersProvider serversProvider = ServersProvider();
  AppConfigProvider configProvider = AppConfigProvider();

  Map<String, dynamic> dbData = await loadDb();
  serversProvider.setDbInstance(dbData['dbInstance']);
  serversProvider.saveFromDb(dbData['servers']);

  PackageInfo appInfo = await loadAppInfo();
  configProvider.setAppInfo(appInfo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => serversProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => configProvider)
        ),
      ],
      child: Phoenix(child: const DroidHole()),
    )
  );
}

Future<Map<String, dynamic>> loadDb() async {
  List<Map<String, Object?>>? servers;

  Database db = await openDatabase(
    'droid_hole.db',
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, token TEXT, isDefaultServer NUMERIC)");
    },
    onOpen: (Database db) async {
      await db.transaction((txn) async{
        servers = await txn.rawQuery(
          'SELECT * FROM servers',
        );
      });
    }
  );
  
  return {
    "servers": servers,
    "dbInstance": db,
  };
}

Future<PackageInfo> loadAppInfo() async {
  return await PackageInfo.fromPlatform();
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
