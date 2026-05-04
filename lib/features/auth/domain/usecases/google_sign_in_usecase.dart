import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<User> call() {
    return repository.signInWithGoogle();
  }
}