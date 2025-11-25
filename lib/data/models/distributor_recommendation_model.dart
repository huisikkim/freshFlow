import 'package:fresh_flow/domain/entities/distributor_recommendation.dart';

class DistributorRecommendationModel extends DistributorRecommendation {
  const DistributorRecommendationModel({
    required super.distributorId,
    required super.distributorName,
    required super.totalScore,
    required super.regionScore,
    required super.productScore,
    required super.deliveryScore,
    required super.certificationScore,
    required super.matchReason,
    required super.supplyProducts,
    required super.serviceRegions,
    required super.deliveryAvailable,
    required super.deliveryInfo,
    required super.certifications,
    required super.minOrderAmount,
    required super.phoneNumber,
    required super.email,
  });

  factory DistributorRecommendationModel.fromJson(Map<String, dynamic> json) {
    return DistributorRecommendationModel(
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
      regionScore: (json['regionScore'] as num).toDouble(),
      productScore: (json['productScore'] as num).toDouble(),
      deliveryScore: (json['deliveryScore'] as num).toDouble(),
      certificationScore: (json['certificationScore'] as num).toDouble(),
      matchReason: json['matchReason'] as String,
      supplyProducts: json['supplyProducts'] as String,
      serviceRegions: json['serviceRegions'] as String,
      deliveryAvailable: json['deliveryAvailable'] as bool,
      deliveryInfo: json['deliveryInfo'] as String,
      certifications: json['certifications'] as String,
      minOrderAmount: json['minOrderAmount'] as int,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
    );
  }
}
