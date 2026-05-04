import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}