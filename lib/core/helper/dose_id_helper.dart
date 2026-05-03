class DoseIdHelper {
  static String generate(String medicineId, DateTime time) {
    final normalized = DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );

    return "$medicineId-${normalized.toIso8601String()}";
  }
}
