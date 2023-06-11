import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/server.dart';
import 'package:sqflite/sqflite.dart';

Future<dynamic> saveServerQuery(Database db, Server server) async {
  try {
    return await db.transaction((txn) async {
      await txn.insert(
        'servers',
        { 
          'address': server.address,
          'alias': server.alias,
          'token': server.token,
          'isDefaultServer': 0,
          'basicAuthUser': server.basicAuthUser,
          'basicAuthPassword': server.basicAuthPassword,
        }
      );
      return null;
    });
  } catch (e) {
    return e;
  }
}

Future<dynamic> editServerQuery(Database db, Server server) async {
  try {
    return await db.transaction((txn) async {
      await txn.update(
        'servers',
        { 
          'alias': server.alias,
          'token': server.token,
          'isDefaultServer': convertFromBoolToInt(server.defaultServer),
          'basicAuthUser': server.basicAuthUser,
          'basicAuthPassword': server.basicAuthPassword,
        },
        where: 'address = ?',
        whereArgs: [server.address]
      );
      return null;
    });
  } catch (e) {
    return e;
  }
}

Future<dynamic> setDefaultServerQuery(Database db, String url) async {
  try {
    return await db.transaction((txn) async {
      await txn.update(
        'servers',
        {'isDefaultServer': '0'},
        where: 'isDefaultServer = ?',
        whereArgs: [1]
      );
      await txn.update(
        'servers',
        {'isDefaultServer': '1'},
        where: 'id = ?',
        whereArgs: [url]
      );
      return null;
    });
  } catch (e) {
    return e;
  }
}

Future<dynamic> setServerTokenQuery(Database db, String? token, String address) async {
  try {
    return await db.transaction((txn) async {
      await txn.update(
        'servers',
        {'token': token ?? ''},
        where: 'address = ?',
        whereArgs: [address]
      );
      return null;
    });
  } catch (e) {
    return e;
  }
}

Future<bool> removeServerQuery(Database db, String address) async {
  try {
    return await db.transaction((txn) async {
      await txn.delete(
        'servers', 
        where: 'address = ?', 
        whereArgs: [address]
      );
      return true;
    });
  } catch (e) {
    return false;
  }
}

Future<bool> deleteServersDataQuery(Database db) async {
  try {
    return await db.transaction((txn) async {
      await txn.delete(
        'servers', 
      );
      return true;
    });
  } catch (e) {
    return false;
  }
}

Future<Map<String, dynamic>> checkUrlExistsQuery(Database db, String url) async {
  try {
    return await db.transaction((txn) async {
      final result = await txn.rawQuery(
        'SELECT count(address) as quantity FROM servers WHERE address = "$url"',
      );
      if (result[0]['quantity'] == 0) {
        return {
          'result': 'success',
          'exists': false
        };
      }
      else {
        return {
          'result': 'success',
          'exists': true
        };
      }
    });
  } catch (e) {
    return {
      'result': 'fail'
    };
  }
}

Future<bool> updateConfigQuery({
  required Database db, 
  required String column,
  required dynamic value
}) async {
  try {
    return await db.transaction((txn) async {
      await txn.update(
        'appConfig',
        { column: value },
      );
      return true;
    });
  } catch (e) {
    return false;
  }
}

Future<bool> restoreAppConfigQuery(Database db) async {
  try {
    return await db.transaction((txn) async {
      await txn.update(
        'appConfig',
        { 
          'autoRefreshTime': 5,
          'theme': 0,
          'overrideSslCheck': 0,
          'oneColumnLegend': 0,
          'reducedDataCharts': 0,
          'logsPerQuery': 2,
          'passCode': null,
          'useBiometricAuth': 0
        },
      );
      return true;
    });
  } catch (e) {
    return false;
  }
}