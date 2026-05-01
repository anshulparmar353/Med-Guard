import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class SaveProfileUserUseCase {
  final ProfileUserRepository repository;

  SaveProfileUserUseCase(this.repository);

  Future<void> call(ProfileUser user) async {
    await repository.saveProfileUser(user);
  }
}