import 'package:med_guard/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);

  Future<User> signInWithGoogle();

  Future<User> signup(String email, String password);

  Future<User?> getCurrentUser();

  Future<void> logout();
}