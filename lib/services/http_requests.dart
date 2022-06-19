import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/models/realtime_status.dart';
import 'package:droid_hole/models/server.dart';

Future<Response> httpClient({String? token, required String url}) async {  
  return http.get(
    Uri.parse(url),
    headers: {
      'Cookie': token != null ? 'persistentlogin=$token' : ''
    }
  ).timeout(
    const Duration(seconds: 10)
  );
}

Future realtimeStatus(Server server) async {
  try {
    final response = await httpClient(
      token: server.token,
      url: '${server.address}/admin/api.php?summaryRaw&topItems&getForwardDestinations&getQuerySources&topClientsBlocked',
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
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic login(Server server) async {
  try {
    final response = await httpClient(
      url: '${server.address}/admin/api.php'
    );
    final body = jsonDecode(response.body);
    if (body['status'] != null) {
      final response2 = await httpClient(
        url: '${server.address}/admin/api.php?auth=${server.token}&${body['status'] == 'enabled' ? 'enable' : 'disable'}'
      );
      final body2 = jsonDecode(response2.body);
      if (body2.runtimeType != List && body2['status'] != null) {
        return {
          'result': 'success',
          'status': body['status']
        };
      }
      else {
        return {'result': 'token_invalid'};
      }
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic disableServer(Server server, int time) async {
  try {
    final response = await httpClient(url: '${server.address}/admin/api.php?auth=${server.token}&disable=$time');
    final body = jsonDecode(response.body);
    if (body.runtimeType != List && body['status'] != null) {
      return {
        'result': 'success',
        'status': body['status']
      };
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}

dynamic enableServer(Server server) async {
  try {
    final response = await httpClient(url: '${server.address}/admin/api.php?auth=${server.token}&enable');
    final body = jsonDecode(response.body);
    if (body.runtimeType != List && body['status'] != null) {
      return {
        'result': 'success',
        'status': body['status']
      };
    }
  } on SocketException {
    return {'result': 'no_connection'};
  } on TimeoutException {
    return {'result': 'no_connection'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}


Future fetchOverTimeData(Server server) async {
  try {
    final response = await httpClient(
      token: server.token,
      url: '${server.address}/admin/api.php?overTimeData10mins',
    );
    final body = jsonDecode(response.body);
    return {
      'result': 'success',
      'data': OverTimeData.fromJson(body)
    };
  } on SocketException {
    return {'result': 'socket'};
  } on TimeoutException {
    return {'result': 'timeout'};
  }
  catch (e) {
    return {'result': 'error'};
  }
}
