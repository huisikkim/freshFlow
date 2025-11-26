import 'package:fresh_flow/domain/entities/distributor_comparison.dart';
import 'package:fresh_flow/domain/repositories/comparison_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/comparison_remote_datasource.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  final ComparisonRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  ComparisonRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  Future<String> _getToken() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }
    return user.accessToken;
  }

  @override
  Future<List<DistributorComparison>> compareTopDistributors({
    int topN = 5,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.compareTopDistributors(
      token: token,
      topN: topN,
    );
  }

  @override
  Future<List<DistributorComparison>> compareDistributors(
      List<String> distributorIds) async {
    final token = await _getToken();
    return await remoteDataSource.compareDistributors(
      token: token,
      distributorIds: distributorIds,
    );
  }

  @override
  Future<Map<String, DistributorComparison>> findBestByCategory(
      List<String> distributorIds) async {
    final token = await _getToken();
    return await remoteDataSource.findBestByCategory(
      token: token,
      distributorIds: distributorIds,
    );
  }
}
