import 'package:sqflite/sqflite.dart';

import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/server.dart';

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

Future upgradeDbToV6(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN overrideSslCheck NUMERIC");
  await db.execute("UPDATE appConfig SET overrideSslCheck = 0");
}

Future upgradeDbToV7(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN oneColumnLegend NUMERIC");
  await db.execute("UPDATE appConfig SET oneColumnLegend = 0");
}

Future upgradeDbToV8(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN reducedDataCharts NUMERIC");
  await db.execute("UPDATE appConfig SET reducedDataCharts = 0");
}

Future upgradeDbToV9(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN logsPerQuery NUMERIC");
  await db.execute("UPDATE appConfig SET logsPerQuery = 2");
}

Future upgradeDbToV10(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN passCode TEXT");
  await db.execute("UPDATE appConfig SET passCode = null");
}

Future upgradeDbToV11(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN useBiometricAuth NUMERIC");
  await db.execute("UPDATE appConfig SET useBiometricAuth = 0");
}

Future upgradeDbToV12(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN importantInfoReaden NUMERIC");
  await db.execute("UPDATE appConfig SET importantInfoReaden = 0");
}

Future upgradeDbToV13(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN hideZeroValues NUMERIC");
  await db.execute("UPDATE appConfig SET hideZeroValues = 0");
}

Future upgradeDbToV14(Database db) async {
  await db.execute("ALTER TABLE appConfig ADD COLUMN statisticsVisualizationMode NUMERIC");
  await db.execute("UPDATE appConfig SET statisticsVisualizationMode = 0");
}

Future upgradeDbToV15(Database db) async {
  List<Map<String, Object?>> backupServers = [];
  await db.transaction((txn) async{
    backupServers = await txn.rawQuery(
      'SELECT * FROM servers',
    );
  });

  List<Server> servers = [];
  for (Map<String, dynamic> server in backupServers) {
    final Server serverObj = Server(
      address: server['address'], 
      alias: server['alias'],
      token: server['pwHash'],
      defaultServer: convertFromIntToBool(server['isDefaultServer'])!,
    );
    servers.add(serverObj);
  }

  await db.execute("DROP TABLE servers");
  await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, token TEXT, isDefaultServer NUMERIC)");

  List<Future> futures = [];
  for (var server in servers) { 
    futures.add(db.execute("INSERT INTO servers (address, alias, token, isDefaultServer) VALUES ('${server.address}', '${server.alias}', '${server.token}', ${server.defaultServer == true ? 1 : 0})"));
  }
  await Future.wait(futures);

  await db.transaction((txn) async{
    await txn.rawQuery('SELECT * FROM servers');
  });
}

Future<Map<String, dynamic>> loadDb() async {
  List<Map<String, Object?>>? servers;
  List<Map<String, Object?>>? appConfig;

  Database db = await openDatabase(
    'droid_hole.db',
    version: 15,
    onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE servers (address TEXT PRIMARY KEY, alias TEXT, token TEXT, isDefaultServer NUMERIC)");
      await db.execute("CREATE TABLE appConfig (autoRefreshTime NUMERIC, theme NUMERIC, overrideSslCheck NUMERIC, oneColumnLegend NUMERIC, reducedDataCharts NUMERIC, logsPerQuery NUMERIC, passCode TEXT, useBiometricAuth NUMERIC, importantInfoReaden NUMERIC, hideZeroValues NUMERIC, statisticsVisualizationMode NUMERIC)");
      await db.execute("INSERT INTO appConfig (autoRefreshTime, theme, overrideSslCheck, oneColumnLegend, reducedDataCharts, logsPerQuery, passCode, useBiometricAuth, importantInfoReaden, hideZeroValues, statisticsVisualizationMode) VALUES (5, 0, 0, 0, 0, 2, null, 0, 0, 0, 0)");
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion == 2) {
        await upgradeDbToV3(db);
        await upgradeDbToV4(db);
        await upgradeDbToV5(db);
        await upgradeDbToV6(db);
        await upgradeDbToV7(db);
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 3) {
        await upgradeDbToV4(db);
        await upgradeDbToV5(db);
        await upgradeDbToV6(db);
        await upgradeDbToV7(db);
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 4) {
        await upgradeDbToV5(db);
        await upgradeDbToV6(db);
        await upgradeDbToV7(db);
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 5) {
        await upgradeDbToV6(db);
        await upgradeDbToV7(db);
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 6) {
        await upgradeDbToV7(db);
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 7) {
        await upgradeDbToV8(db);
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 8) {
        await upgradeDbToV9(db);
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 9) {
        await upgradeDbToV10(db);
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 10) {
        await upgradeDbToV11(db);
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 11) {
        await upgradeDbToV12(db);
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 12) {
        await upgradeDbToV13(db);
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 13) {
        await upgradeDbToV14(db);
        await upgradeDbToV15(db);
      }
      if (oldVersion == 14) {
        await upgradeDbToV15(db);
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