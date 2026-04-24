import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';

class AuthLocalDataSource {
  final Box<UserModel> box;

  AuthLocalDataSource(this.box);

  static const String userKey = "user";

  Future<void> cacheUser(UserModel user) async {
    await box.put(userKey, user);
  }

  UserModel? getUser() {
    return box.get(userKey);
  }

  Future<void> clear() async {
    await box.delete(userKey);
  }
}
