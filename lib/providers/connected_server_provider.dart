import 'package:flutter/material.dart';

import 'package:droid_hole/models/server.dart';

class ConnectedServerProvider with ChangeNotifier {
  Server? server;
  bool? isEnabled;
}