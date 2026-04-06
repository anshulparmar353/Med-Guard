import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class SignupUsecase {
  final AuthRepository repository;

  SignupUsecase(this.repository);

  Future<User> call(String email, String password) {
    return repository.signup(email, password);
  }
}