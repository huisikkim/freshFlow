import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
import 'package:fresh_flow/domain/repositories/matching_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/matching_remote_datasource.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  MatchingRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<List<DistributorRecommendation>> getRecommendations({
    int limit = 10,
  }) async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    return await remoteDataSource.getRecommendations(
      token: user.accessToken,
      limit: limit,
    );
  }
}
