import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<String> signUp({
    required String username,
    required String password,
    required String email,
    required String userType,
    required String businessNumber,
    required String businessName,
    required String ownerName,
    required String phoneNumber,
    required String address,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
}
