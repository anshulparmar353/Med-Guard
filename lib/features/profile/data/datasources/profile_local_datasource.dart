import 'package:hive/hive.dart';
import '../models/profile_user_model.dart';

class ProfileLocalDataSource {
  final Box<ProfileUserModel> box;

  ProfileLocalDataSource(this.box);

  ProfileUserModel? getUser(String userId) {
    return box.get(userId);
  }

  Future<void> saveUser(ProfileUserModel user) async {
    await box.put(user.id, user);
  }

  Future<void> clearUser(String userId) async {
    await box.delete(userId);
  }

  Stream<ProfileUserModel?> watchUser(String userId) async* {
    yield box.get(userId);

    yield* box.watch(key: userId).map((event) {
      return box.get(userId);
    });
  }
}
