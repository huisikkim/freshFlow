class User {
  final int userId;
  final String username;
  final String accessToken;
  final String tokenType;
  final String userType;
  final String businessName;
  final String? storeId;
  final String? distributorId;

  const User({
    required this.userId,
    required this.username,
    required this.accessToken,
    required this.tokenType,
    required this.userType,
    required this.businessName,
    this.storeId,
    this.distributorId,
  });
}
