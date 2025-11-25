import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/quote_request_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class QuoteRequestRemoteDataSource {
  Future<QuoteRequestModel> createQuoteRequest({
    required String token,
    required String distributorId,
    required String requestedProducts,
    String? message,
  });

  Future<List<QuoteRequestModel>> getStoreQuoteRequests(String token);

  Future<List<QuoteRequestModel>> getDistributorQuoteRequests(String token);

  Future<QuoteRequestModel> getQuoteRequestDetail(String token, int quoteId);

  Future<QuoteRequestModel> respondToQuoteRequest({
    required String token,
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  });

  Future<QuoteRequestModel> completeQuoteRequest(String token, int quoteId);

  Future<void> cancelQuoteRequest(String token, int quoteId);
}

class QuoteRequestRemoteDataSourceImpl
    implements QuoteRequestRemoteDataSource {
  final http.Client client;

  QuoteRequestRemoteDataSourceImpl(this.client);

  @override
  Future<QuoteRequestModel> createQuoteRequest({
    required String token,
    required String distributorId,
    required String requestedProducts,
    String? message,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quoteRequestEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'distributorId': distributorId,
          'requestedProducts': requestedProducts,
          if (message != null) 'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return QuoteRequestModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('견적 요청 생성 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<List<QuoteRequestModel>> getStoreQuoteRequests(String token) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.storeQuoteRequestsEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => QuoteRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception('견적 목록 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<List<QuoteRequestModel>> getDistributorQuoteRequests(
      String token) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.distributorQuoteRequestsEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => QuoteRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception('견적 목록 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<QuoteRequestModel> getQuoteRequestDetail(
      String token, int quoteId) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteRequestEndpoint}/$quoteId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return QuoteRequestModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('견적 상세 조회 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<QuoteRequestModel> respondToQuoteRequest({
    required String token,
    required int quoteId,
    required String status,
    int? estimatedAmount,
    required String response,
  }) async {
    try {
      final res = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteRequestEndpoint}/$quoteId/respond'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          if (estimatedAmount != null) 'estimatedAmount': estimatedAmount,
          'response': response,
        }),
      );

      if (res.statusCode == 200) {
        return QuoteRequestModel.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
      } else {
        throw Exception('견적 응답 실패 (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<QuoteRequestModel> completeQuoteRequest(
      String token, int quoteId) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteRequestEndpoint}/$quoteId/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return QuoteRequestModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('견적 완료 처리 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelQuoteRequest(String token, int quoteId) async {
    try {
      final response = await client.delete(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteRequestEndpoint}/$quoteId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('견적 취소 실패 (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }
}
