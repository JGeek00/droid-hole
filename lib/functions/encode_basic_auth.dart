import 'dart:convert';

// Basic auth token works by encoding using base64 this string: "username:password"

String encodeBasicAuth(String username, String password) {
  return base64.encode(utf8.encode('$username:$password'));
}