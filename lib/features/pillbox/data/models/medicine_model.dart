import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/medicine.dart';

@HiveType(typeId: 2)
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

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.updatedAt,
    required this.isDeleted,
  });

  Medicine toEntity() {
    return Medicine(
      id: id,
      name: name,
      dosage: dosage,
      times: times,
      updateAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  static MedicineModel fromEntity(Medicine med) {
    return MedicineModel(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      times: med.times,
      updatedAt: med.updateAt,
      isDeleted: med.isDeleted,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: (json['times'] as List)
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "dosage": dosage,
      "times": times.map((e) => Timestamp.fromDate(e)).toList(),
      "updatedAt": Timestamp.fromDate(updatedAt),
      "isDeleted": isDeleted,
    };
  }
}
