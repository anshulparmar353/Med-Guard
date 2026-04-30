class Reminder {
  final int id;
  final String payload;
  final String medicineName;
  final DateTime time;

  Reminder({
    required this.id,
    required this.payload,
    required this.medicineName,
    required this.time,
  });
}
