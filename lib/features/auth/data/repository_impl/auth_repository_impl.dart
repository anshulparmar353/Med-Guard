import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/auth/domain/entities/user.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.firebaseAuth,
  });

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remote.login(email, password);

    await local.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User> signup(String email, String password) async {
    final userModel = await remote.signUp(email, password);

    await local.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User?> getCurrentUser() async {
    final cached = local.getUser();
    if (cached != null) return cached.toEntity();

    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final user = User(id: firebaseUser.uid, email: firebaseUser.email ?? '');

    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
          "923707869253-79gio97si504kgnbjdj1gptckosqrpgq.apps.googleusercontent.com",
    );

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);

    final firebaseUser = userCredential.user!;

    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
    );

    await local.cacheUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await GoogleSignIn.instance.signOut();
    await local.clear();
  }
}
