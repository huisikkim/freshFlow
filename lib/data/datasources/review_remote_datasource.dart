import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/core/errors/exceptions.dart';
import 'package:fresh_flow/data/models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<StoreReviewModel> createStoreReview({
    required String token,
    required int orderId,
    required int rating,
    required String comment,
    required int deliveryQuality,
    required int productQuality,
    required int serviceQuality,
  });

  Future<DistributorReviewModel> createDistributorReview({
    required String token,
    required int orderId,
    required int rating,
    required String comment,
    required int paymentReliability,
    required int communicationQuality,
    required int orderAccuracy,
  });

  Future<ReviewStatisticsModel> getReviewStatistics(String token);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final http.Client client;

  ReviewRemoteDataSourceImpl(this.client);

  @override
  Future<StoreReviewModel> createStoreReview({
    required String token,
    required int orderId,
    required int rating,
    required String comment,
    required int deliveryQuality,
    required int productQuality,
    required int serviceQuality,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createStoreReviewEndpoint}');

    final body = {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'deliveryQuality': deliveryQuality,
      'productQuality': productQuality,
      'serviceQuality': serviceQuality,
    };

    print('⭐ 가게사장님 리뷰 작성 요청');
    print('URL: $uri');
    print('Body: ${json.encode(body)}');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StoreReviewModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to create review';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<DistributorReviewModel> createDistributorReview({
    required String token,
    required int orderId,
    required int rating,
    required String comment,
    required int paymentReliability,
    required int communicationQuality,
    required int orderAccuracy,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createDistributorReviewEndpoint}');

    final body = {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'paymentReliability': paymentReliability,
      'communicationQuality': communicationQuality,
      'orderAccuracy': orderAccuracy,
    };

    print('⭐ 유통업자 리뷰 작성 요청');
    print('URL: $uri');
    print('Body: ${json.encode(body)}');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DistributorReviewModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to create review';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<ReviewStatisticsModel> getReviewStatistics(String token) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.reviewStatisticsEndpoint}');

    print('📊 리뷰 통계 조회 요청');
    print('URL: $uri');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      return ReviewStatisticsModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch review statistics');
    }
  }
}
