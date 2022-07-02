// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final hash1 = sha256.convert(utf8.encode(password)).toString();
  return sha256.convert(utf8.encode(hash1)).toString();
}