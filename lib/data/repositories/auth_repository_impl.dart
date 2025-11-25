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
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<String> signUp(String username, String password, String email) async {
    try {
      final result = await remoteDataSource.signUp(username, password, email);
      return result;
    } catch (e) {
      throw AuthFailure(e.toString());
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
}
