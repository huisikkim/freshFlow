import 'package:fresh_flow/domain/entities/quote_request.dart';
import 'package:fresh_flow/domain/repositories/quote_request_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/quote_request_remote_datasource.dart';

class QuoteRequestRepositoryImpl implements QuoteRequestRepository {
  final QuoteRequestRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  QuoteRequestRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  Future<String> _getToken() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }
    return user.accessToken;
  }

  @override
  Future<QuoteRequest> createQuoteRequest({
    required String distributorId,
    required String requestedProducts,
    String? message,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.createQuoteRequest(
      token: token,
      distributorId: distributorId,
      requestedProducts: requestedProducts,
      message: message,
    );
  }

  @override
  Future<List<QuoteRequest>> getStoreQuoteRequests() async {
    final token = await _getToken();
    return await remoteDataSource.getStoreQuoteRequests(token);
  }

  @override
  Future<List<QuoteRequest>> getDistributorQuoteRequests() async {
    final token = await _getToken();
    return await remoteDataSource.getDistributorQuoteRequests(token);
  }

  @override
  Future<QuoteRequest> getQuoteRequestDetail(int quoteId) async {
    final token = await _getToken();
    return await remoteDataSource.getQuoteRequestDetail(token, quoteId);
  }

  @override
  Future<QuoteRequest> respondToQuoteRequest({
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.respondToQuoteRequest(
      token: token,
      quoteId: quoteId,
      status: status,
      estimatedAmount: estimatedAmount,
      response: response,
    );
  }

  @override
  Future<QuoteRequest> completeQuoteRequest(int quoteId) async {
    final token = await _getToken();
    return await remoteDataSource.completeQuoteRequest(token, quoteId);
  }

  @override
  Future<void> cancelQuoteRequest(int quoteId) async {
    final token = await _getToken();
    return await remoteDataSource.cancelQuoteRequest(token, quoteId);
  }
}
