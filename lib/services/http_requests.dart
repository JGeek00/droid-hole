// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:droid_hole/models/domain.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' show parse;

import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/models/realtime_status.dart';
import 'package:droid_hole/models/server.dart';

Future<Response> httpClient({
  required String method, 
  String? token, 
  required String url,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  int? timeout,
}) async {  
  switch (method) {
    case 'post':
      return http.post(
        Uri.parse(url),
        body: body
      ).timeout(
        const Duration(seconds: 10)
      );
    
    case 'get':
    default:
      return http.get(
        Uri.parse(url),
        headers: headers
      ).timeout(
        Duration(seconds: timeout ??  10)
      );
  }
}

Future realtimeStatus(Server server, String token) async {;
  try {
    final response = await httpClient(
      method: 'get',
      url: '${server.address}/admin/api.php?summaryRaw&topItems&getForwardDestinations&getQuerySources&topClientsBlocked&getQueryTypes',
      headers: {
        'Cookie': "persistentLogin=${server.pwHash};PHPSESSID=$token;"
      }
    );
    final body = jsonDecode(response.body);
    if (body['status'] != null) {
      return {
        'result': 'success',
        'data': RealtimeStatus.fromJson(body)
      };
    }
  } on SocketException {
    return {'result': 'socket'};
  } on TimeoutException {
    return {'result': 'timeout'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic login(Server server) async {
  try {
    final hasPassword = await httpClient(
      method: 'get', 
      url: '${server.address}/admin/index.php?login',
    );
    String phpSessId = hasPassword.headers['set-cookie']!.split(';')[0].split('=')[1];
    if (hasPassword.statusCode == 200) {
      final document = parse(hasPassword.body);
      final pwField = document.getElementById('loginpw');
      if (pwField != null) {
        // Server has password
        final loginReq = http.MultipartRequest(
          'POST',
          Uri.parse('${server.address}/admin/index.php?login'),
        )..fields.addAll({
          'pw': server.password,
          'persistentLogin': 'false'
        });
        final loginRes = await loginReq.send().timeout(
          const Duration(seconds: 10)
        );
        final parsedResult = parse(await loginRes.stream.bytesToString());
        final token = parsedResult.getElementById('token');
        if (loginRes.statusCode == 200 && token != null) {
          phpSessId = loginRes.headers['set-cookie']!.split(';')[0].split('=')[1];
          final statusReq = await httpClient(
            method: 'get',
            url: '${server.address}/admin/api.php'
          );
          final status = jsonDecode(statusReq.body);
          if (statusReq.statusCode == 200 && status.runtimeType != List && status['status'] != null) {
            return {
              'result': 'success',
              'status': status['status'],
              'phpSessId': phpSessId,
              'token': token.text,
              'withPassword': true
            };
          }
          else {
            return {'result': 'no_connection'};
          }
        }
        else {
          return {'result': 'token_invalid'};
        }
      }
      else {
        // Server doesn't have password
        final token = document.getElementById('token')!.text;
        final statusReq = await httpClient(
          method: 'get',
          url: '${server.address}/admin/api.php'
        );
        final status = jsonDecode(statusReq.body);
        if (statusReq.statusCode == 200 && status.runtimeType != List && status['status'] != null) {
          return {
            'result': 'success',
            'status': status['status'],
            'phpSessId': phpSessId,
            'token': token,
            'withPassword': false
          };
        }
        else {
          return {'result': 'no_connection'};
        }
      }
    }
    else {
      return {'result': 'no_connection'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'timeout'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic disableServerRequest(Server server, String token, String phpSessId, int time) async {
  try {
    final response = await httpClient(
      method: 'get', 
      url: '${server.address}/admin/api.php?auth=${server.pwHash}&disable=$time',
      headers: {
        'Cookie': 'PHPSESSID=$phpSessId'
      }
    );
    final body = jsonDecode(response.body);
    if (body.runtimeType != List && body['status'] != null) {
      return {
        'result': 'success',
        'status': body['status']
      };
    }
    else {
      return {'result': 'error'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic enableServerRequest(Server server, String token, String phpSessId) async {
  try {
    final response = await httpClient(
      method: 'get', 
      url: '${server.address}/admin/api.php?auth=${server.pwHash}&enable',
      headers: {
        'Cookie': 'PHPSESSID=$phpSessId'
      }
    );
    final body = jsonDecode(response.body);
    if (body.runtimeType != List && body['status'] != null) {
      return {
        'result': 'success',
        'status': body['status']
      };
    }
    else {
      return {'result': 'error'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}


Future fetchOverTimeData(Server server, String phpSessId) async {
  try {
    final response = await httpClient(
      method: 'get',
      url: '${server.address}/admin/api.php?overTimeData10mins&overTimeDataClients&getClientNames',
      headers: {
        'Cookie': 'PHPSESSID=$phpSessId'
      }
    );
    final body = jsonDecode(response.body);
    var data = OverTimeData.fromJson(body);
    return {
      'result': 'success',
      'data': data
    };
  } on SocketException {
    return {'result': 'socket'};
  } on TimeoutException {
    return {'result': 'timeout'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

Future fetchLogs({
  required Server server, 
  required String phpSessId, 
  required DateTime from, 
  required DateTime until, 
}) async {
  try {
    final response = await httpClient(
      method: 'get',
      url: '${server.address}/admin/api.php?getAllQueries&from=${from.millisecondsSinceEpoch~/1000}&until=${until.millisecondsSinceEpoch~/1000}',
      headers: {
        'Cookie': 'PHPSESSID=$phpSessId'
      },
      timeout: 20
    );
    final body = jsonDecode(response.body);
    return {
      'result': 'success',
      'data': body['data']
    };
  } on SocketException {
    return {'result': 'socket'};
  } on TimeoutException {
    return {'result': 'timeout'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

Future setWhiteBlacklist({
  required Server server, 
  required String domain,
  required String list,
  required String token, 
  required String phpSessId
}) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${server.address}/admin/scripts/pi-hole/php/groups.php'),
    )..fields.addAll({
      'domain': domain,
      'list': list,
      'token': token,
      'action': 'replace_domain'
    });
    request.headers.addAll({
      'Cookie': 'PHPSESSID=$phpSessId'
    });
    final res = await request.send().timeout(
      const Duration(seconds: 10)
    );
    final response = await res.stream.bytesToString();
    final responseJson = jsonDecode(response);
    if (responseJson['success'] == true) {
      return {
        'result': 'success',
        'data': responseJson
      };
    }
    else {
      return {
        'result': 'token'
      };
    }
  } on FormatException {
    return {'result': 'token'};
  } on SocketException {
    return {'result': 'socket'};
  } on TimeoutException {
    return {'result': 'timeout'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
} 

dynamic testHash(Server server, String hash) async {
  try {
    final status = await httpClient(
      method: 'get',
      url: '${server.address}/admin/api.php',
    );
    if (status.statusCode == 200) {
      final body = jsonDecode(status.body);
      if (body.runtimeType != List && body['status'] != null) {
        final response = await httpClient(
          method: 'get', 
          url: '${server.address}/admin/api.php?auth=$hash&${body['status'] == 'enabled' ? 'enable' : 'disable'}',
        );
        if (response.statusCode == 200) {
          final body2 = jsonDecode(response.body);
          if (body2.runtimeType != List && body2['status'] != null) {
            return {'result': 'success'};
          }
          else {
            return {'result': 'hash_not_valid'};
          }
        }
        else {
          return {'result': 'hash_not_valid'};
        }
      }
      else {
        return {'result': 'no_connection'};
      }
    }
    else {
      return {'result': 'no_connection'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

Future getDomainLists({
  required Server server
}) async {
  try {
    final results = await Future.wait([
      http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=white')),
      http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=regex_white')),
      http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=black')),
      http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=regex_black')),
    ]);

    if (
      results[0].statusCode == 200 &&
      results[1].statusCode == 200 &&
      results[2].statusCode == 200 &&
      results[3].statusCode == 200 
    ) {
      return {
        'result': 'success',
        'data': {
          'whitelist': jsonDecode(results[0].body)['data'].map((item) => Domain.fromJson(item)) ,
          'whitelistRegex': jsonDecode(results[1].body)['data'].map((item) => Domain.fromJson(item)),
          'blacklist': jsonDecode(results[2].body)['data'].map((item) => Domain.fromJson(item)),
          'blacklistRegex': jsonDecode(results[3].body)['data'].map((item) => Domain.fromJson(item)),
        }
      };
    }
    else {
      return {
        'result': 'error'
      };
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  } on FormatException {
    return {'result': 'auth_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

Future removeDomainFromList({
  required Server server,
  required Domain domain
}) async {
  String getType(int type) {
    switch (type) {
      case 0:
        return "white";

      case 1:
        return "black";

      case 2:
        return "regex_black";

      case 3:
        return "regex_white";

      default:
        return "";
    }
  }

  try {
    final result = await http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=${getType(domain.type)}&sub=${domain.domain}'));
    if (result.statusCode == 200) {
      final json = jsonDecode(result.body);
      if (json.runtimeType == List<dynamic>) {
        return {'result': 'error', 'message': 'not_exists'};
      }
      else {
        if (json['success'] == true) {
          return {'result': 'success'};
        }
        else {
          return {'result': 'error'};
        }
      }
    }
    else {
      return {'result': 'error'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  } on FormatException {
    return {'result': 'auth_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

Future addDomainToList({
  required Server server,
  required Map<String, dynamic> domainData,
}) async {
  try {
    final result = await http.get(Uri.parse('${server.address}/admin/api.php?auth=${server.pwHash}&list=${domainData['list']}&add=${domainData['domain']}'));
    if (result.statusCode == 200) {
      final json = jsonDecode(result.body);
      if (json.runtimeType == List<dynamic>) {
        return {'result': 'error'};
      }
      else {
        if (json['success'] == true && json['message'] == 'Added ${domainData['domain']}') {
          return {'result': 'success'};
        }
        else if (json['success'] == true && json['message'] == 'Not adding ${domainData['domain']} as it is already on the list') {
          return {'result': 'already_added'};
        }
        else {
          return {'result': 'error'};
        }
      }
    }
    else {
      return {'result': 'error'};
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  } on HandshakeException {
    return {'result': 'ssl_error'};
  } on FormatException {
    return {'result': 'auth_error'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}