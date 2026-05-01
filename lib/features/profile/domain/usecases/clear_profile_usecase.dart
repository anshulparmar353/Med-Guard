import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class ClearProfileUseCase {
  final ProfileUserRepository repo;

  ClearProfileUseCase(this.repo);

  Future<void> call(String userId) {
    return repo.clearProfile(userId);
  }
}