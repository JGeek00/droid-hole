// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vibration/vibration.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/base.dart';
import 'package:droid_hole/screens/unlock.dart';

import 'package:droid_hole/services/database/database.dart';
import 'package:droid_hole/classes/http_override.dart';
import 'package:droid_hole/config/theme.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/functions/status_updater.dart';
import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(500, 500));
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await dotenv.load(fileName: '.env');

  ServersProvider serversProvider = ServersProvider();
  StatusProvider statusProvider = StatusProvider();
  FiltersProvider filtersProvider = FiltersProvider();
  DomainsListProvider domainsListProvider = DomainsListProvider();
  AppConfigProvider configProvider = AppConfigProvider();

  Map<String, dynamic> dbData = await loadDb();

  if (dbData['appConfig']['overrideSslCheck'] == 1) {
    HttpOverrides.global = MyHttpOverrides();
  }

  serversProvider.setDbInstance(dbData['dbInstance']);
  configProvider.saveFromDb(dbData['dbInstance'], dbData['appConfig']);
  await serversProvider.saveFromDb(
    dbData['servers'], 
    dbData['appConfig']['passCode'] != null ? false : true
  );

  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final bool canAuthenticateWithBiometrics = await LocalAuthentication.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await LocalAuthentication.getAvailableBiometrics();
      configProvider.setBiometricsSupport(canAuthenticateWithBiometrics);
      
      if (
        canAuthenticateWithBiometrics && 
        availableBiometrics.contains(BiometricType.fingerprint) == false && 
        dbData['useBiometricAuth'] == 1
      ) {
        await configProvider.setUseBiometrics(false);
      }
    }
  } catch (e) {
    configProvider.setBiometricsSupport(false);
  }

  try {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Vibration.hasCustomVibrationsSupport() != null) {
        configProvider.setValidVibrator(true);
      }
      else {
        configProvider.setValidVibrator(false);
      }
    }
  } catch (e) {
    configProvider.setValidVibrator(false);
  }

  PackageInfo appInfo = await loadAppInfo();
  configProvider.setAppInfo(appInfo);

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    configProvider.setAndroidInfo(androidInfo);
  }
  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    configProvider.setIosInfo(iosInfo);
  }

  void startApp() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => serversProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => statusProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => filtersProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => domainsListProvider)
        ),
        ChangeNotifierProvider(
          create: ((context) => configProvider)
        ),
        ChangeNotifierProxyProvider<AppConfigProvider, ServersProvider>(
          create: (context) => serversProvider, 
          update: (context, appConfig, servers) => servers!..update(appConfig),
        ),
      ],
      child: Phoenix(
        child: const DroidHole()
      ), 
    )
  );

  if (
    (
      kReleaseMode &&
      (dotenv.env['SENTRY_DSN'] != null && dotenv.env['SENTRY_DSN'] != "")
    ) || (
      dotenv.env['ENABLE_SENTRY'] == "true" &&
      (dotenv.env['SENTRY_DSN'] != null && dotenv.env['SENTRY_DSN'] != "")
    )
  ) {
    SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN'];
        options.sendDefaultPii = false;
      },
      appRunner: () => startApp()
    );
  }
  else {
    startApp();
  }
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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      displayMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    if (statusProvider.startAutoRefresh == true || statusProvider.getRefreshServerStatus == true) {
      statusUpdater.context = context;
      if (statusProvider.getRefreshServerStatus == true) {
        statusProvider.setRefreshServerStatus(false);
      }
      statusUpdater.statusData();
      statusUpdater.overTimeData();

      statusProvider.setStartAutoRefresh(false);
    }

    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Droid Hole',
          theme: appConfigProvider.androidDeviceInfo != null && appConfigProvider.androidDeviceInfo!.version.sdkInt >= 31
            ? lightTheme(lightDynamic)
            : lightThemeOldVersions(),
          darkTheme: appConfigProvider.androidDeviceInfo != null && appConfigProvider.androidDeviceInfo!.version.sdkInt >= 31
            ? darkTheme(darkDynamic)
            : darkThemeOldVersions(),
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
            Locale('es', ''),
            Locale('de', '')
          ],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: !(Platform.isAndroid || Platform.isIOS) 
                  ? 0.9
                  : 1.0
              ),
              child: AppLock(
                builder: (_, __) => child!, 
                lockScreen: const Unlock(),
                enabled: appConfigProvider.passCode != null ? true : false,
                backgroundLockLatency: const Duration(seconds: 0),
              )
            );
          },
          home: const Base()
        );
      }),
    );
  }
}