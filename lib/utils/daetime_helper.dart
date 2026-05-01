  import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw Exception("Invalid date type");
  }


