import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';

class AuthLocalDataSource {
  final Box box;

  AuthLocalDataSource(this.box);

  static const String userKey = "user";

  Future<void> cacheUser(UserModel user) async {
    await box.put(userKey, {
      "id": user.id,
      "email": user.email,
    });
  }

  UserModel? getUser() {
    final data = box.get(userKey);
    if (data == null) return null;

    return UserModel(
      id: data['id'],
      email: data['email'],
    );
  }

  Future<void> clear() async {
    await box.delete(userKey);
  }
}