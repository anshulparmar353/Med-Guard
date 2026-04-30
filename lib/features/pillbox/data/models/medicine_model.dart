import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/medicine.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 3)
class MedicineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dosage;

  @HiveField(3)
  List<DateTime> times;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  bool isDeleted;

  @HiveField(6)
  bool isDaily;

  @HiveField(7)
  DateTime? startDate; // ✅ NEW

  @HiveField(8)
  DateTime? endDate; // ✅ NEW

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDaily,
    this.startDate,
    this.endDate,
  });

  // ================= ENTITY =================

  Medicine toEntity() {
    return Medicine(
      id: id,
      name: name,
      dosage: dosage,
      times: times,
      updatedAt: updatedAt, // ✅ FIXED
      isDeleted: isDeleted,
      isDaily: isDaily,
      startDate: startDate, // ✅ NEW
      endDate: endDate, // ✅ NEW
    );
  }

  static MedicineModel fromEntity(Medicine med) {
    return MedicineModel(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      times: med.times,
      updatedAt: med.updatedAt, // ✅ FIXED
      isDeleted: med.isDeleted,
      isDaily: med.isDaily,
      startDate: med.startDate, // ✅ NEW
      endDate: med.endDate, // ✅ NEW
    );
  }

  // ================= JSON =================

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',

      times:
          (json['times'] as List?)?.map((e) => DateTime.parse(e)).toList() ??
          [],

      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),

      isDeleted: json['isDeleted'] ?? false,
      isDaily: json['isDaily'] ?? true,

      startDate: json['startDate'] == null
          ? null
          : (json['startDate'] is Timestamp
                ? (json['startDate'] as Timestamp).toDate()
                : DateTime.parse(json['startDate'])),

      endDate: json['endDate'] == null
          ? null
          : (json['endDate'] is Timestamp
                ? (json['endDate'] as Timestamp).toDate()
                : DateTime.parse(json['endDate'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "dosage": dosage,
      "times": times.map((e) => e.toIso8601String()).toList(),
      "updatedAt": updatedAt.toIso8601String(),
      "isDeleted": isDeleted,
      "isDaily": isDaily,
      "startDate": startDate?.toIso8601String(), // ✅ NEW
      "endDate": endDate?.toIso8601String(), // ✅ NEW
    };
  }
}
