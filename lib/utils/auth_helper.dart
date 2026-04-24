import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  final FirebaseAuth auth;

  AuthHelper(this.auth);

  String? get userId => auth.currentUser?.uid;

  bool get isLoggedIn => auth.currentUser != null;
}