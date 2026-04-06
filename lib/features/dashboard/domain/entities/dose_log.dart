import 'dose_status.dart';

class DoseLog {
  final String id;
  final String medicineId;
  final String medicineName;
  final int notificationId;
  final DateTime scheduledTime;
  final DateTime? takenAt;
  final DoseStatus status;
  final DateTime updatedAt;

  DoseLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.notificationId,
    required this.scheduledTime,
    required this.status,
    required this.updatedAt,
    this.takenAt,
  });
}
