import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';
import 'package:fresh_flow/domain/usecases/get_recommendations_usecase.dart';

enum MatchingState { initial, loading, success, error }

class MatchingProvider extends ChangeNotifier {
  final GetRecommendationsUseCase getRecommendationsUseCase;

  MatchingState _state = MatchingState.initial;
  List<DistributorRecommendation> _recommendations = [];
  String? _errorMessage;

  MatchingState get state => _state;
  List<DistributorRecommendation> get recommendations => _recommendations;
  String? get errorMessage => _errorMessage;

  MatchingProvider({required this.getRecommendationsUseCase});

  Future<void> loadRecommendations({int limit = 10}) async {
    _state = MatchingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await getRecommendationsUseCase.execute(limit: limit);
      _state = MatchingState.success;
      notifyListeners();
    } catch (e) {
      _state = MatchingState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = MatchingState.initial;
    _recommendations = [];
    _errorMessage = null;
    notifyListeners();
  }
}
