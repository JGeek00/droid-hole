import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
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
  await serversProvider.saveFromDb(dbData['servers']);
  configProvider.saveFromDb(dbData['dbInstance'], dbData['appConfig']);

  PackageInfo appInfo = await loadAppInfo();
  configProvider.setAppInfo(appInfo);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: const Color.fromRGBO(250, 250, 250, 1),
    statusBarColor: Colors.transparent, 
    statusBarBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.black.withOpacity(0.05),
    systemNavigationBarIconBrightness: Brightness.dark
  ));
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
  List<Map<String, Object?>>? appConfig;

  Database db = await openDatabase(
    'droid_hole.db',
    version: 2,
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, token TEXT, isDefaultServer NUMERIC)");
      await db.execute("CREATE TABLE appConfig (autoRefreshTime NUMERIC)");
      await db.execute("INSERT INTO appConfig (autoRefreshTime) VALUES (5)");
    },
    onOpen: (Database db) async {
      await db.transaction((txn) async{
        servers = await txn.rawQuery(
          'SELECT * FROM servers',
        );
      });
      await db.transaction((txn) async{
        appConfig = await txn.rawQuery(
          'SELECT * FROM appConfig',
        );
      });
    }
  );

  return {
    "servers": servers,
    "appConfig": appConfig![0],
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
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? active;
  DisplayMode? preferred;

  Future<void> displayMode() async {
    try {
      modes = await FlutterDisplayMode.supported;
    } on PlatformException catch (_) {
      // --- //
    }

    preferred = await FlutterDisplayMode.preferred;
    active = await FlutterDisplayMode.active;
    await FlutterDisplayMode.setHighRefreshRate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      displayMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    return MaterialApp(
      title: 'Droid Hole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Base(
        refreshTime: appConfigProvider.getAutoRefreshTime!,
      )
    );
  }
}
