import 'package:hive/hive.dart';
import 'package:med_guard/features/auth/domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  UserModel({
    required this.id,
    required this.email,
  });

  /// 🔁 Entity → Model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
    );
  }

  /// 🔁 Model → Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
    };
  }
}