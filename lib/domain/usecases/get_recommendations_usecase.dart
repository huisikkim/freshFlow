import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
import 'package:fresh_flow/domain/repositories/matching_repository.dart';

class GetRecommendationsUseCase {
  final MatchingRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<List<DistributorRecommendation>> execute({int limit = 10}) async {
    return await repository.getRecommendations(limit: limit);
  }
}
