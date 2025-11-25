import 'package:fresh_flow/domain/entities/quote_request.dart';

abstract class QuoteRequestRepository {
  // 매장용
  Future<QuoteRequest> createQuoteRequest({
    required String distributorId,
    required String requestedProducts,
    String? message,
  });

  Future<List<QuoteRequest>> getStoreQuoteRequests();

  Future<QuoteRequest> completeQuoteRequest(int quoteId);

  Future<void> cancelQuoteRequest(int quoteId);

  // 유통업체용
  Future<List<QuoteRequest>> getDistributorQuoteRequests();

  Future<QuoteRequest> respondToQuoteRequest({
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  });

  // 공통
  Future<QuoteRequest> getQuoteRequestDetail(int quoteId);
}
