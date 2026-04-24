import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dose_log.dart';
import '../../domain/entities/dose_status.dart';

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

  // =========================
  // 🔁 ENTITY CONVERSION
  // =========================

  DoseLog toEntity() {
    return DoseLog(
      id: id,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
      takenAt: takenAt,
      status: DoseStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => DoseStatus.pending,
      ),
      updatedAt: updatedAt,
      notificationId: notificationId,
    );
  }

  factory DoseLogModel.fromEntity(DoseLog e) {
    return DoseLogModel(
      id: e.id,
      medicineId: e.medicineId,
      medicineName: e.medicineName,
      scheduledTime: e.scheduledTime,
      takenAt: e.takenAt,
      status: e.status.name,
      updatedAt: e.updatedAt,
      notificationId: e.notificationId,
      isDeleted: false,
    );
  }

  // =========================
  // 🔁 FIRESTORE PARSING
  // =========================

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'] ?? '',
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      scheduledTime: _parseDate(json['scheduledTime']),
      takenAt: json['takenAt'] != null
          ? _parseDate(json['takenAt'])
          : null,
      status: json['status'] ?? DoseStatus.pending.name,
      updatedAt: _parseDate(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
      notificationId: json['notificationId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      "id": id,
      "medicineId": medicineId,
      "medicineName": medicineName,
      "scheduledTime": Timestamp.fromDate(scheduledTime),
      "status": status,
      "updatedAt": Timestamp.fromDate(updatedAt),
      "isDeleted": isDeleted,
      "notificationId": notificationId,
    };

    if (takenAt != null) {
      map["takenAt"] = Timestamp.fromDate(takenAt!);
    }

    return map;
  }

  // =========================
  // 🔁 COPY WITH
  // =========================

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

  // =========================
  // 🔧 SAFE DATE PARSER
  // =========================

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}