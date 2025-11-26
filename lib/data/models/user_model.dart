import 'package:fresh_flow/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.username,
    required super.accessToken,
    required super.tokenType,
    required super.userType,
    required super.businessName,
    super.storeId,
    super.distributorId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userType = (json['userType'] as String?) ?? 'STORE_OWNER';
    final username = json['username'] as String;
    
    // storeId가 없으면 username을 사용 (STORE_OWNER인 경우)
    String? storeId = json['storeId'] as String?;
    if (storeId == null && userType == 'STORE_OWNER') {
      storeId = username;
    }
    
    // distributorId가 없으면 username을 사용 (DISTRIBUTOR인 경우)
    String? distributorId = json['distributorId'] as String?;
    if (distributorId == null && userType == 'DISTRIBUTOR') {
      distributorId = username;
    }
    
    return UserModel(
      userId: json['userId'] as int,
      username: username,
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userType: userType,
      businessName: (json['businessName'] as String?) ?? '',
      storeId: storeId,
      distributorId: distributorId,
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
      if (storeId != null) 'storeId': storeId,
      if (distributorId != null) 'distributorId': distributorId,
    };
  }
}
