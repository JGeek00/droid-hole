import 'dart:async';

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

import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/config/theme.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/functions/status_updater.dart';
import 'package:auto_route/auto_route.dart';
import 'package:droid_hole/routers/router.gr.dart';
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

Future<Map<String, dynamic>> loadDb() async {
  List<Map<String, Object?>>? servers;
  List<Map<String, Object?>>? appConfig;

  Database db = await openDatabase(
    'droid_hole.db',
    version: 4,
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, password TEXT, isDefaultServer NUMERIC)");
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

    return MaterialApp.router(
      title: 'Droid Hole',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appConfigProvider.selectedTheme,
      debugShowCheckedModeBanner: false,
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
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
    );
  }
}


class Base extends StatelessWidget {
  const Base({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
        systemNavigationBarColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      ),
      child: AutoTabsScaffold(
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
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}