class DoseIdHelper {
  static String generate(String medicineId, DateTime time) {
    return "$medicineId-${time.toIso8601String()}";
  }
}
