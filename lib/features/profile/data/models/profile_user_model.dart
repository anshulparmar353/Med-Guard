import 'package:hive/hive.dart';
import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_guard/utils/daetime_helper.dart';

part 'profile_user_model.g.dart';

@HiveType(typeId: 10)
class ProfileUserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String? caregiverPhone;

  @HiveField(4)
  bool emergencyEnabled;

  @HiveField(5)
  DateTime updatedAt;

  ProfileUserModel({
    required this.id,
    required this.name,
    required this.age,
    this.caregiverPhone,
    required this.emergencyEnabled,
    required this.updatedAt,
  });

  factory ProfileUserModel.fromEntity(ProfileUser user) {
    return ProfileUserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      caregiverPhone: user.caregiverPhone,
      emergencyEnabled: user.emergencyEnabled,
      updatedAt: user.updatedAt,
    );
  }

  ProfileUser toEntity() {
    return ProfileUser(
      id: id,
      name: name,
      age: age,
      caregiverPhone: caregiverPhone,
      emergencyEnabled: emergencyEnabled,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "age": age,
      "caregiverPhone": caregiverPhone,
      "emergencyEnabled": emergencyEnabled,
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json["id"],
      name: json["name"] ?? "",
      age: json["age"] ?? 0,
      caregiverPhone: json["caregiverPhone"],
      emergencyEnabled: json["emergencyEnabled"] ?? false,
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }
}
