import 'package:fresh_flow/domain/entities/distributor_comparison.dart';

abstract class ComparisonRepository {
  Future<List<DistributorComparison>> compareTopDistributors({int topN = 5});

  Future<List<DistributorComparison>> compareDistributors(
      List<String> distributorIds);

  Future<Map<String, DistributorComparison>> findBestByCategory(
      List<String> distributorIds);
}
