import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class UpdateEmergencySettingUseCase {
  final ProfileUserRepository repository;

  UpdateEmergencySettingUseCase(this.repository);

  Future<void> call({
    required ProfileUser user,
    required bool enabled,
  }) async {
    final updated = ProfileUser(
      id: user.id,
      name: user.name,
      age: user.age,
      caregiverPhone: user.caregiverPhone,
      emergencyEnabled: enabled,
      updatedAt: DateTime.now(),
    );

    await repository.saveProfileUser(updated);
  }
}