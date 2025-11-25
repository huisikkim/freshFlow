import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';

abstract class MatchingRepository {
  Future<List<DistributorRecommendation>> getRecommendations({int limit = 10});
}
