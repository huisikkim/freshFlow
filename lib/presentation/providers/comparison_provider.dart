import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/distributor_comparison.dart';
import 'package:fresh_flow/domain/usecases/comparison_usecases.dart';

enum ComparisonState { initial, loading, success, error }

class ComparisonProvider extends ChangeNotifier {
  final CompareTopDistributorsUseCase compareTopDistributorsUseCase;
  final CompareDistributorsUseCase compareDistributorsUseCase;
  final FindBestByCategoryUseCase findBestByCategoryUseCase;

  ComparisonState _state = ComparisonState.initial;
  List<DistributorComparison> _comparisons = [];
  Map<String, DistributorComparison> _bestByCategory = {};
  String? _errorMessage;

  ComparisonState get state => _state;
  List<DistributorComparison> get comparisons => _comparisons;
  Map<String, DistributorComparison> get bestByCategory => _bestByCategory;
  String? get errorMessage => _errorMessage;

  ComparisonProvider({
    required this.compareTopDistributorsUseCase,
    required this.compareDistributorsUseCase,
    required this.findBestByCategoryUseCase,
  });

  Future<void> loadTopComparisons({int topN = 5}) async {
    _state = ComparisonState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _comparisons = await compareTopDistributorsUseCase.execute(topN: topN);
      _state = ComparisonState.success;
      notifyListeners();
    } catch (e) {
      _state = ComparisonState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> compareSelected(List<String> distributorIds) async {
    _state = ComparisonState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _comparisons = await compareDistributorsUseCase.execute(distributorIds);
      _state = ComparisonState.success;
      notifyListeners();
    } catch (e) {
      _state = ComparisonState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadBestByCategory(List<String> distributorIds) async {
    _state = ComparisonState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _bestByCategory =
          await findBestByCategoryUseCase.execute(distributorIds);
      _state = ComparisonState.success;
      notifyListeners();
    } catch (e) {
      _state = ComparisonState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = ComparisonState.initial;
    _comparisons = [];
    _bestByCategory = {};
    _errorMessage = null;
    notifyListeners();
  }
}
