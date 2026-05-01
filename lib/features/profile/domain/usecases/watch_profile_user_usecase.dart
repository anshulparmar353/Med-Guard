import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class WatchProfileUserUseCase {
  final ProfileUserRepository repo;

  WatchProfileUserUseCase(this.repo);

  Stream<ProfileUser?> call(String userId) {
    return repo.watchProfileUser(userId);
  }
}