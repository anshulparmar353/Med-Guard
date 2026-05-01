import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class GetProfileUserUseCase {
  final ProfileUserRepository repo;

  GetProfileUserUseCase(this.repo);

  Future<ProfileUser?> call(String userId) {
    return repo.getProfileUser(userId);
  }
}