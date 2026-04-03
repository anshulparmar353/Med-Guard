class User {
  final String id;
  final String email;
  final String accessToken;
  final String refreshToken;

  User({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });
}