import 'dose_status.dart';

class DoseLog {
  final String id;
  final String medicineId;
  final String medicineName;
  final DateTime scheduledTime;

  final DoseStatus status; 

  final DateTime? takenAt;
  final DateTime updatedAt;
  final int? notificationId;

  DoseLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    required this.status,
    required this.updatedAt,
    this.takenAt,
    this.notificationId,
  });
}
