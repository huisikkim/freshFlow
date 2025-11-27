import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/data/datasources/auth_local_datasource.dart';
import 'package:fresh_flow/data/datasources/auth_remote_datasource.dart';
import 'package:fresh_flow/domain/entities/user.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      await localDataSource.cacheUser(userModel);
      return userModel;
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.signUp(
        username: username,
        password: password,
        email: email,
        userType: userType,
        businessNumber: businessNumber,
        businessName: businessName,
        ownerName: ownerName,
        phoneNumber: phoneNumber,
        address: address,
      );
      return result;
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearCache();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getCachedUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await localDataSource.getCachedUser();
    return user != null;
  }

  @override
  Future<String?> getAccessToken() async {
    final user = await localDataSource.getCachedUser();
    return user?.accessToken;
  }
}
