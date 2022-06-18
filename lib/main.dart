import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:auto_route/auto_route.dart';
import 'package:droid_hole/routers/router.gr.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

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
    statusBarColor: Colors.transparent, 
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: const Color.fromRGBO(250, 250, 250, 1),
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
  final _appRouter = AppRouter();

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

  int selectedScreen = 0;

  Timer? timer;

  int? previousRefreshTime;
  void update(ServersProvider serversProvider, AppConfigProvider appConfigProvider) {
    // Sets previousRefreshTime when is not initialized
    previousRefreshTime ??= appConfigProvider.getAutoRefreshTime;

    bool isRunning = false; // Prevents async request from being executed when last one is not completed yet
    timer = Timer.periodic(Duration(seconds: appConfigProvider.getAutoRefreshTime!), (timer) async {
      // Restarts the timer when time changes
      if (appConfigProvider.getAutoRefreshTime != previousRefreshTime) {
        timer.cancel();
        previousRefreshTime = appConfigProvider.getAutoRefreshTime;
        update(serversProvider, appConfigProvider);
      }

      if (isRunning == false) {
        isRunning = true;
        if (serversProvider.connectedServer != null) {
          final statusResult = await status(serversProvider.connectedServer!);
          if (statusResult['result'] == 'success') {
            serversProvider.updateConnectedServerStatus(
              statusResult['data']['status'] == 'enabled' ? true : false
            );
          }
          isRunning = false;
        }
        else {
          timer.cancel();
        }
      }
    });
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

    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    if (serversProvider.isServerConnected == true && timer == null) {
      update(serversProvider, appConfigProvider);
    }
    else if (serversProvider.isServerConnected == true && timer != null && timer!.isActive == false) {
      update(serversProvider, appConfigProvider);
    }
    else if (serversProvider.isServerConnected == false && timer != null) {
      timer!.cancel();
    }

    return MaterialApp.router(
      title: 'Droid Hole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}


class Base extends StatelessWidget {
  const Base({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRouter(),
        StatisticsRouter(),
        ListsRouter(),
        SettingsRouter()
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavBar(
          selectedScreen: tabsRouter.activeIndex,
          onChange: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}