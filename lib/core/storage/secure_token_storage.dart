import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  final FlutterSecureStorage storage;

  SecureTokenStorage(this.storage);

  static const _accessTokenKey = "accessToken";
  static const _refreshTokenKey = "refreshToken";

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}