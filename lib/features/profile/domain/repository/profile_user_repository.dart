import 'package:med_guard/features/profile/domain/entities/profile_user.dart';

abstract class ProfileUserRepository {
  Future<ProfileUser?> getProfileUser(String userId);
  Future<void> saveProfileUser(ProfileUser user);
  Stream<ProfileUser?> watchProfileUser(String userId);
  Future<void> clearProfile(String userId);
}
