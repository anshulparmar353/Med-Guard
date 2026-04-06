import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remote.login(email, password);

    await local.cacheUser(userModel);

    return userModel.toEntity(); // ✅ ensure mapping exists
  }

  @override
  Future<User> signup(String email, String password) async {
    final userModel = await remote.signUp(email, password);

    await local.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User?> getCachedUser() async {
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return null;

    // Optional: use local cache
    final cached = local.getUser();
    if (cached != null) return cached.toEntity();

    // fallback from Firebase
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
    );
  }

  @override
  Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut(); // ✅ Firebase logout
    await local.clear();
  }
}