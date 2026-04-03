import 'package:dio/dio.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(
      "/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    return UserModel.fromJson(response.data);
  }

  Future<UserModel> signUp(String email, String password) async {
    final response = await dio.post(
      "/signup",
      data: {
        "email": email,
        "password": password,
      },
    );

    return UserModel.fromJson(response.data);
  }
}