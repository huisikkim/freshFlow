import 'package:fresh_flow/domain/entities/review.dart';

class StoreReviewModel extends StoreReview {
  StoreReviewModel({
    required super.id,
    required super.orderId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.deliveryQuality,
    required super.productQuality,
    required super.serviceQuality,
  });

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: json['id'].toString(),
      orderId: json['orderId'] as int,
      reviewerId: json['reviewerId'] as String,
      revieweeId: json['revieweeId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveryQuality: json['deliveryQuality'] as int,
      productQuality: json['productQuality'] as int,
      serviceQuality: json['serviceQuality'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'deliveryQuality': deliveryQuality,
      'productQuality': productQuality,
      'serviceQuality': serviceQuality,
    };
  }
}

class DistributorReviewModel extends DistributorReview {
  DistributorReviewModel({
    required super.id,
    required super.orderId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.paymentReliability,
    required super.communicationQuality,
    required super.orderAccuracy,
  });

  factory DistributorReviewModel.fromJson(Map<String, dynamic> json) {
    return DistributorReviewModel(
      id: json['id'].toString(),
      orderId: json['orderId'] as int,
      reviewerId: json['reviewerId'] as String,
      revieweeId: json['revieweeId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentReliability: json['paymentReliability'] as int,
      communicationQuality: json['communicationQuality'] as int,
      orderAccuracy: json['orderAccuracy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'paymentReliability': paymentReliability,
      'communicationQuality': communicationQuality,
      'orderAccuracy': orderAccuracy,
    };
  }
}

class ReviewStatisticsModel extends ReviewStatistics {
  ReviewStatisticsModel({
    required super.averageRating,
    required super.totalReviews,
    required super.ratingDistribution,
  });

  factory ReviewStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatisticsModel(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      ratingDistribution: Map<int, int>.from(
        (json['ratingDistribution'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value as int),
        ),
      ),
    );
  }
}
