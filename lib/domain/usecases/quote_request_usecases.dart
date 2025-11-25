import 'package:fresh_flow/domain/entities/quote_request.dart';
import 'package:fresh_flow/domain/repositories/quote_request_repository.dart';

// 견적 요청 생성
class CreateQuoteRequestUseCase {
  final QuoteRequestRepository repository;

  CreateQuoteRequestUseCase(this.repository);

  Future<QuoteRequest> execute({
    required String distributorId,
    required String requestedProducts,
    String? message,
  }) async {
    return await repository.createQuoteRequest(
      distributorId: distributorId,
      requestedProducts: requestedProducts,
      message: message,
    );
  }
}

// 매장 견적 목록 조회
class GetStoreQuoteRequestsUseCase {
  final QuoteRequestRepository repository;

  GetStoreQuoteRequestsUseCase(this.repository);

  Future<List<QuoteRequest>> execute() async {
    return await repository.getStoreQuoteRequests();
  }
}

// 유통업체 견적 목록 조회
class GetDistributorQuoteRequestsUseCase {
  final QuoteRequestRepository repository;

  GetDistributorQuoteRequestsUseCase(this.repository);

  Future<List<QuoteRequest>> execute() async {
    return await repository.getDistributorQuoteRequests();
  }
}

// 견적 응답
class RespondToQuoteRequestUseCase {
  final QuoteRequestRepository repository;

  RespondToQuoteRequestUseCase(this.repository);

  Future<QuoteRequest> execute({
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  }) async {
    return await repository.respondToQuoteRequest(
      quoteId: quoteId,
      status: status,
      estimatedAmount: estimatedAmount,
      response: response,
    );
  }
}

// 견적 완료
class CompleteQuoteRequestUseCase {
  final QuoteRequestRepository repository;

  CompleteQuoteRequestUseCase(this.repository);

  Future<QuoteRequest> execute(int quoteId) async {
    return await repository.completeQuoteRequest(quoteId);
  }
}

// 견적 취소
class CancelQuoteRequestUseCase {
  final QuoteRequestRepository repository;

  CancelQuoteRequestUseCase(this.repository);

  Future<void> execute(int quoteId) async {
    return await repository.cancelQuoteRequest(quoteId);
  }
}
