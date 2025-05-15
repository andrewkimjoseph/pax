import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pax/models/local/activity_model.dart';

String formatTimestampWithIntl(Timestamp? timestamp) {
  if (timestamp == null) return 'N/A';

  final date = timestamp.toDate();

  // Format the date using DateFormat
  final DateFormat monthDayYearFormat = DateFormat('MMM d yyyy');
  final DateFormat timeFormat = DateFormat('h.mm a');

  final String datePart = monthDayYearFormat.format(date);
  final String timePart = timeFormat.format(date);

  return '$datePart | $timePart';
}

extension FormatActivityTimeStamp on Activity {
  String get formattedTimestamp => formatTimestampWithIntl(timestamp);
}
