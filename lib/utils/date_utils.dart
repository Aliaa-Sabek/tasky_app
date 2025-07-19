
import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd MMM yyyy – hh:mm a').format(dateTime);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
