import 'package:dio/dio.dart';
import 'package:med_guard/core/storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureTokenStorage secure;

  AuthInterceptor(this.dio, this.secure);

  @override
  void onRequest(options, handler) async {
    final token = await secure.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/refresh-token')) {
      try {
        final newToken = await _refreshToken();

        err.requestOptions.headers['Authorization'] =
            'Bearer $newToken';

        final response = await dio.fetch(err.requestOptions);

        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<String> _refreshToken() async {
    final refreshToken = await secure.getRefreshToken();

    final response = await dio.post(
      "/refresh-token",
      data: {
        "refreshToken": refreshToken,
      },
    );

    final newAccessToken = response.data['accessToken'];

    // Save updated access token
    await secure.saveTokens(
      accessToken: newAccessToken,
      refreshToken: refreshToken!,
    );

    return newAccessToken;
  }
}