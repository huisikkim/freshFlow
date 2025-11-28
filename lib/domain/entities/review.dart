class Review {
  final String id;
  final int orderId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class StoreReview extends Review {
  final int deliveryQuality;
  final int productQuality;
  final int serviceQuality;

  StoreReview({
    required super.id,
    required super.orderId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required this.deliveryQuality,
    required this.productQuality,
    required this.serviceQuality,
  });
}

class DistributorReview extends Review {
  final int paymentReliability;
  final int communicationQuality;
  final int orderAccuracy;

  DistributorReview({
    required super.id,
    required super.orderId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required this.paymentReliability,
    required this.communicationQuality,
    required this.orderAccuracy,
  });
}

class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}
