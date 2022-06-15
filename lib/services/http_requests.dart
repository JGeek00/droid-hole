import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'package:droid_hole/models/server.dart';

Future<Response> httpClient(String url) {
  return http.get(Uri.parse(url)).timeout(
    const Duration(seconds: 10)
  );
}

Future status(Server server) async {
  try {
    final response = await httpClient('${server.address}/admin/api.php');
    final body = jsonDecode(response.body);
    if (body['status'] != null) {
      return {
        'result': 'success',
        'data': body
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

dynamic login(Server server) async {
  try {
    final response = await httpClient('${server.address}/admin/api.php');
    final body = jsonDecode(response.body);
    if (body['status'] != null) {
      final response2 = await httpClient('${server.address}/admin/api.php?auth=${server.token}&${body['status'] == 'enabled' ? 'enable' : 'disable'}');
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
    final response = await httpClient('${server.address}/admin/api.php?auth=${server.token}&disable=$time');
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
    final response = await httpClient('${server.address}/admin/api.php?auth=${server.token}&enable');
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