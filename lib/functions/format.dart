import 'package:intl/intl.dart';

String formatTimestamp(DateTime timestamp, String format) {
  DateFormat f = DateFormat(format);
  return f.format(timestamp);
}