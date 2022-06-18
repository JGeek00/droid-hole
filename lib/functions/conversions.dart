import 'package:intl/intl.dart';

bool? convertFromIntToBool(int value) {
  if (value == 1) {
    return true;
  }
  else if (value == 0) {
    return false;
  }
  else {
    return null;
  }
}

int? convertFromBoolToInt(bool value) {
  if (value == true) {
    return 1;
  }
  else if (value == false) {
    return 0;
  }
  else {
    return null;
  }
}

double formatPercentage(double value) {
  return (value * 100).truncateToDouble() / 100;
}

String intFormat(int value, String locale) {
  final f = NumberFormat("#,###", locale);
  return f.format(value);
}