import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import '../../domain/entities/dose_log.dart';

part 'dose_log_model.g.dart';

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
  final DateTime? takenAt;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool isDeleted;

  @HiveField(8)
  final int? notificationId;

  DoseLogModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    required this.status,
    required this.updatedAt,
    required this.notificationId,
    this.takenAt,
    this.isDeleted = false,
  });

  DoseLog toEntity() {
    return DoseLog(
      id: id,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,

      status: mapStatus(status),

      updatedAt: updatedAt,
      takenAt: takenAt,
      notificationId: notificationId,
    );
  }

  static DoseLogModel fromEntity(DoseLog e) {
    return DoseLogModel(
      id: e.id,
      medicineId: e.medicineId,
      medicineName: e.medicineName,
      scheduledTime: e.scheduledTime,

      status: e.status.name,

      updatedAt: e.updatedAt,
      takenAt: e.takenAt,
      notificationId: e.notificationId,
    );
  }

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'],
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      scheduledTime: _parseDate(json['scheduledTime']),
      status: json['status'] ?? "pending",
      updatedAt: _parseDate(json['updatedAt']),
      takenAt: json['takenAt'] != null ? _parseDate(json['takenAt']) : null,
      notificationId: json['notificationId'],
    );
  }

  Map<String, dynamic> toFirestoreJson() {
    final map = {
      "id": id,
      "medicineId": medicineId,
      "medicineName": medicineName,
      "scheduledTime": Timestamp.fromDate(scheduledTime),
      "status": status,
      "updatedAt": Timestamp.fromDate(updatedAt),
      "isDeleted": isDeleted,
      "notificationId": notificationId ?? 0,
    };

    if (takenAt != null) {
      map["takenAt"] = Timestamp.fromDate(takenAt!);
    }

    return map;
  }

  Map<String, dynamic> toLocalJson() {
    return {
      "id": id,
      "medicineId": medicineId,
      "medicineName": medicineName,
      "scheduledTime": scheduledTime.toIso8601String(),
      "status": status,
      "updatedAt": updatedAt.toIso8601String(),
      "isDeleted": isDeleted,
      "notificationId": notificationId ?? 0,
      "takenAt": takenAt?.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;

      // fallback
      return DateTime.now();
    } catch (e) {
      print("❌ DATE PARSE FAILED: $value");
      return DateTime.now();
    }
  }

  DoseLogModel copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    DateTime? scheduledTime,
    DateTime? takenAt,
    String? status,
    DateTime? updatedAt,
    bool? isDeleted,
    int? notificationId,
  }) {
    return DoseLogModel(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenAt: takenAt,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
