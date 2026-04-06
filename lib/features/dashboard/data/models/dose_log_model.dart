import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dose_log.dart';
import '../../domain/entities/dose_status.dart';

@HiveType(typeId: 1)
class DoseLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineId;

  @HiveField(2)
  final String medicineName;

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  DateTime? takenAt;

  @HiveField(5)
  String status;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isDeleted;

  @HiveField(8)
  final int notificationId;

  DoseLogModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
    required this.updatedAt,
    required this.notificationId,
    this.isDeleted = false,
  });

  // 🔁 Convert to Domain Entity
  DoseLog toEntity() {
    return DoseLog(
      id: id,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
      takenAt: takenAt,
      status: DoseStatus.values.firstWhere((e) => e.name == status),
      updatedAt: updatedAt,
      notificationId: notificationId,
    );
  }

  // 🔁 Convert from Domain Entity
  factory DoseLogModel.fromEntity(DoseLog e) {
    return DoseLogModel(
      id: e.id,
      medicineId: e.medicineId,
      medicineName: e.medicineName,
      scheduledTime: e.scheduledTime,
      takenAt: e.takenAt,
      status: e.status.name,
      updatedAt: e.updatedAt,
      isDeleted: false,
      notificationId: e.notificationId,
    );
  }

  // 🔁 Firestore → Model
  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'],
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
      takenAt: json['takenAt'] != null
          ? (json['takenAt'] as Timestamp).toDate()
          : null,
      status: json['status'],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isDeleted: json['isDeleted'] ?? false,
      notificationId: json['notificationId'],
    );
  }

  // 🔁 Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "medicineId": medicineId,
      "medicineName": medicineName,
      "scheduledTime": Timestamp.fromDate(scheduledTime),
      "takenAt": takenAt != null ? Timestamp.fromDate(takenAt!) : null,
      "status": status,
      "updatedAt": Timestamp.fromDate(updatedAt),
      "isDeleted": isDeleted,
      "notificationId": notificationId,
    };
  }
}
