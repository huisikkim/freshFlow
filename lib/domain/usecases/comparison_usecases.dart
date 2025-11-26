import 'package:fresh_flow/domain/entities/distributor_comparison.dart';
import 'package:fresh_flow/domain/repositories/comparison_repository.dart';

class CompareTopDistributorsUseCase {
  final ComparisonRepository repository;

  CompareTopDistributorsUseCase(this.repository);

  Future<List<DistributorComparison>> execute({int topN = 5}) async {
    return await repository.compareTopDistributors(topN: topN);
  }
}

class CompareDistributorsUseCase {
  final ComparisonRepository repository;

  CompareDistributorsUseCase(this.repository);

  Future<List<DistributorComparison>> execute(
      List<String> distributorIds) async {
    return await repository.compareDistributors(distributorIds);
  }
}

class FindBestByCategoryUseCase {
  final ComparisonRepository repository;

  FindBestByCategoryUseCase(this.repository);

  Future<Map<String, DistributorComparison>> execute(
      List<String> distributorIds) async {
    return await repository.findBestByCategory(distributorIds);
  }
}
