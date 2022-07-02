// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:droid_hole/functions/server_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/logs.dart';
import 'package:droid_hole/screens/settings.dart';
import 'package:droid_hole/screens/statistics.dart';

import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/config/theme.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/functions/status_updater.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServersProvider serversProvider = ServersProvider();
  FiltersProvider filtersProvider = FiltersProvider();
  AppConfigProvider configProvider = AppConfigProvider();

  Map<String, dynamic> dbData = await loadDb();
  serversProvider.setDbInstance(dbData['dbInstance']);
  await serversProvider.saveFromDb(dbData['servers']);
  configProvider.saveFromDb(dbData['dbInstance'], dbData['appConfig']);

  PackageInfo appInfo = await loadAppInfo();
  configProvider.setAppInfo(appInfo);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => serversProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => filtersProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => configProvider)
        ),
      ],
      child: Phoenix(child: const DroidHole()),
    )
  );
}

Future upgradeDbToV3(Database db) async {
  await db.execute("ALTER TABLE servers RENAME COLUMN token TO password");
}

Future downgradeToV3(Database db) async {
  await db.execute("DROP TABLE appConfig");
  await db.execute("CREATE TABLE appConfig (autoRefreshTime NUMERIC)");
  await db.execute("INSERT INTO appConfig (autoRefreshTime) VALUES (5)");
}

Future upgradeDbToV4(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN theme NUMERIC");
  await db.execute("UPDATE appConfig SET theme = 0");
}

Future upgradeDbToV5(Database db) async {
  await db.execute("ALTER TABLE servers ADD COLUMN pwHash TEXT");
  await db.execute("DELETE FROM servers");
}

Future<Map<String, dynamic>> loadDb() async {
  List<Map<String, Object?>>? servers;
  List<Map<String, Object?>>? appConfig;

  Database db = await openDatabase(
    'droid_hole.db',
    version: 5,
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, password TEXT, pwHash TEXT, isDefaultServer NUMERIC)");
      await db.execute("CREATE TABLE appConfig (autoRefreshTime NUMERIC, theme NUMERIC)");
      await db.execute("INSERT INTO appConfig (autoRefreshTime, theme) VALUES (5, 0)");
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion == 2) {
        await upgradeDbToV3(db);
        await upgradeDbToV4(db);
      }
      if (oldVersion == 3) {
        await upgradeDbToV4(db);
      }
      if (oldVersion == 4) {
        await upgradeDbToV5(db);
      }
    },
    onDowngrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion == 4 && newVersion == 3) {
        await downgradeToV3(db);
      }
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
      preferred = await FlutterDisplayMode.preferred;
      active = await FlutterDisplayMode.active;
      await FlutterDisplayMode.setHighRefreshRate();
      setState(() {});
    } catch (_) {
      // ---- //
    }
  }

  final StatusUpdater statusUpdater = StatusUpdater();
  bool firstExec = true;

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

    if (firstExec == true || serversProvider.getRefreshServerStatus == true) {
      if (serversProvider.getRefreshServerStatus == true) {
        serversProvider.setRefreshServerStatus(false);
      }
      statusUpdater.statusData(context);
      statusUpdater.overTimeData(context);
      setState(() {
        firstExec = false;
      });
    }

    return MaterialApp(
      title: 'Droid Hole',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appConfigProvider.selectedTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', '')
      ],
      home: const Base()
    );
  }
}


class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key); 

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int selectedScreen = 0;

  final List<Widget> pages = [
    const Home(),
    const Statistics(),
    const Logs(),
    const Settings()
  ];

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    void _enableDisableServer() async {
      if (
        serversProvider.isServerConnected == true &&
        serversProvider.selectedServer != null
      ) {
        if (serversProvider.selectedServer?.enabled == true) {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            builder: (_) => DisableModal(
              onDisable: (time) => disableServer(time, context)
            ),
            backgroundColor: Colors.transparent,
            isDismissible: false,
            enableDrag: false,
          );
        }
        else {
          enableServer(context);
        }
      }
    }
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.light
          : Brightness.dark,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
        systemNavigationBarColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      ),
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (
            (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
              animation: primaryAnimation, 
              secondaryAnimation: secondaryAnimation,
              child: child,
            )
          ),
          child: pages[selectedScreen],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedScreen: selectedScreen,
          onChange: (selected) => setState((() => selectedScreen = selected)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: selectedScreen == 0
          ? serversProvider.selectedServer != null
            && serversProvider.isServerConnected == true
              ? FloatingActionButton(
                  onPressed: _enableDisableServer,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.shield_rounded),
                )
              : null
          : null,
      ),
    );
  }
}