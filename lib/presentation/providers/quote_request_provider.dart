import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/quote_request.dart';
import 'package:fresh_flow/domain/usecases/quote_request_usecases.dart';

enum QuoteRequestState { initial, loading, success, error }

class QuoteRequestProvider extends ChangeNotifier {
  final CreateQuoteRequestUseCase createQuoteRequestUseCase;
  final GetStoreQuoteRequestsUseCase getStoreQuoteRequestsUseCase;
  final GetDistributorQuoteRequestsUseCase getDistributorQuoteRequestsUseCase;
  final RespondToQuoteRequestUseCase respondToQuoteRequestUseCase;
  final CompleteQuoteRequestUseCase completeQuoteRequestUseCase;
  final CancelQuoteRequestUseCase cancelQuoteRequestUseCase;

  QuoteRequestState _state = QuoteRequestState.initial;
  List<QuoteRequest> _quoteRequests = [];
  QuoteRequest? _currentQuoteRequest;
  String? _errorMessage;

  QuoteRequestState get state => _state;
  List<QuoteRequest> get quoteRequests => _quoteRequests;
  QuoteRequest? get currentQuoteRequest => _currentQuoteRequest;
  String? get errorMessage => _errorMessage;

  QuoteRequestProvider({
    required this.createQuoteRequestUseCase,
    required this.getStoreQuoteRequestsUseCase,
    required this.getDistributorQuoteRequestsUseCase,
    required this.respondToQuoteRequestUseCase,
    required this.completeQuoteRequestUseCase,
    required this.cancelQuoteRequestUseCase,
  });

  Future<void> createQuoteRequest({
    required String distributorId,
    required String requestedProducts,
    String? message,
  }) async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentQuoteRequest = await createQuoteRequestUseCase.execute(
        distributorId: distributorId,
        requestedProducts: requestedProducts,
        message: message,
      );
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStoreQuoteRequests() async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _quoteRequests = await getStoreQuoteRequestsUseCase.execute();
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDistributorQuoteRequests() async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _quoteRequests = await getDistributorQuoteRequestsUseCase.execute();
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> respondToQuoteRequest({
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  }) async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentQuoteRequest = await respondToQuoteRequestUseCase.execute(
        quoteId: quoteId,
        status: status,
        estimatedAmount: estimatedAmount,
        response: response,
      );
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeQuoteRequest(int quoteId) async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentQuoteRequest = await completeQuoteRequestUseCase.execute(quoteId);
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancelQuoteRequest(int quoteId) async {
    _state = QuoteRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await cancelQuoteRequestUseCase.execute(quoteId);
      _state = QuoteRequestState.success;
      notifyListeners();
    } catch (e) {
      _state = QuoteRequestState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = QuoteRequestState.initial;
    _quoteRequests = [];
    _currentQuoteRequest = null;
    _errorMessage = null;
    notifyListeners();
  }
}
