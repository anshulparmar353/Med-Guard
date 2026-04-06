import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("Login failed");
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
    );
  }

  Future<UserModel> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("Signup failed");
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}