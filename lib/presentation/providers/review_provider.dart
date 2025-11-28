import 'package:flutter/material.dart';
import 'package:fresh_flow/data/datasources/review_remote_datasource.dart';
import 'package:fresh_flow/domain/entities/review.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

enum ReviewState { initial, loading, loaded, error }

class ReviewProvider with ChangeNotifier {
  final ReviewRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  ReviewProvider({
    required this.remoteDataSource,
    required this.authRepository,
  });

  ReviewState _state = ReviewState.initial;
  ReviewStatistics? _statistics;
  String? _errorMessage;

  ReviewState get state => _state;
  ReviewStatistics? get statistics => _statistics;
  String? get errorMessage => _errorMessage;

  Future<bool> createStoreReview({
    required int orderId,
    required int rating,
    required String comment,
    required int deliveryQuality,
    required int productQuality,
    required int serviceQuality,
  }) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      await remoteDataSource.createStoreReview(
        token: token,
        orderId: orderId,
        rating: rating,
        comment: comment,
        deliveryQuality: deliveryQuality,
        productQuality: productQuality,
        serviceQuality: serviceQuality,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      final errorMessage = e.toString();
      // 이미 리뷰를 작성한 경우 특별 처리
      if (errorMessage.contains('이미 리뷰를 작성한') ||
          errorMessage.contains('already reviewed')) {
        _errorMessage = '이미 리뷰를 작성한 주문입니다';
      } else {
        _errorMessage = errorMessage;
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> createDistributorReview({
    required int orderId,
    required int rating,
    required String comment,
    required int paymentReliability,
    required int communicationQuality,
    required int orderAccuracy,
  }) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      await remoteDataSource.createDistributorReview(
        token: token,
        orderId: orderId,
        rating: rating,
        comment: comment,
        paymentReliability: paymentReliability,
        communicationQuality: communicationQuality,
        orderAccuracy: orderAccuracy,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      final errorMessage = e.toString();
      // 이미 리뷰를 작성한 경우 특별 처리
      if (errorMessage.contains('이미 리뷰를 작성한') ||
          errorMessage.contains('already reviewed')) {
        _errorMessage = '이미 리뷰를 작성한 주문입니다';
      } else {
        _errorMessage = errorMessage;
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> getReviewStatistics() async {
    _state = ReviewState.loading;
    notifyListeners();

    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _statistics = await remoteDataSource.getReviewStatistics(token);
      _state = ReviewState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = ReviewState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
