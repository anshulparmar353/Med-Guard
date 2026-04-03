import 'package:med_guard/core/storage/secure_token_storage.dart';
import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final SecureTokenStorage secure;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.secure,
  });

  @override
  Future<User> login(String email, String password) async {
    final user = await remote.login(email, password);

    // Save separately
    await local.cacheUser(user);

    await secure.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );

    return user;
  }

  @override
  Future<User?> getCachedUser() async {
    final accessToken = await secure.getAccessToken();
    final refreshToken = await secure.getRefreshToken();

    if (accessToken == null || refreshToken == null) return null;

    return local.getUser(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> logout() async {
    await local.clear();
    await secure.clearTokens();
  }

  @override
  Future<User> signup(String email, String password) async {
    final user = await remote.signUp(email, password);

    return user;
  }
}
