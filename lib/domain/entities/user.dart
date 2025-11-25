class User {
  final int userId;
  final String username;
  final String accessToken;
  final String tokenType;

  const User({
    required this.userId,
    required this.username,
    required this.accessToken,
    required this.tokenType,
  });
}
