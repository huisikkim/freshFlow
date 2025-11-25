import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}
