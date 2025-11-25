import 'package:fresh_flow/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.username,
    required super.accessToken,
    required super.tokenType,
    required super.userType,
    required super.businessName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      username: json['username'] as String,
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userType: (json['userType'] as String?) ?? 'STORE_OWNER',
      businessName: (json['businessName'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'accessToken': accessToken,
      'tokenType': tokenType,
      'userType': userType,
      'businessName': businessName,
    };
  }
}
