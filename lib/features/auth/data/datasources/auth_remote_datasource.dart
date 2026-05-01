import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:med_guard/features/profile/data/models/profile_user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileRemoteDataSource profileRemote;

  AuthRemoteDataSource(this.profileRemote);

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) throw Exception("Login failed");

      return UserModel(id: user.uid, email: user.email ?? '');
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  Future<UserModel> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) throw Exception("Signup failed");

      final userModel = UserModel(id: user.uid, email: user.email ?? '');

      await profileRemote.uploadProfile(
        ProfileUserModel(
          id: user.uid,
          name: "",
          age: 0,
          caregiverPhone: null,
          emergencyEnabled: false,
          updatedAt: DateTime.now(),
        ),
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  UserModel? getCurrentUser() {
    final user = _auth.currentUser;

    if (user == null) return null;

    return UserModel(id: user.uid, email: user.email ?? '');
  }

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;

      return UserModel(id: user.uid, email: user.email ?? '');
    });
  }
}
