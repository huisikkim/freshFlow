import 'package:fresh_flow/domain/entities/distributor_comparison.dart';

class DistributorComparisonModel extends DistributorComparison {
  const DistributorComparisonModel({
    required super.distributorId,
    required super.distributorName,
    required super.phoneNumber,
    required super.email,
    required super.totalScore,
    required super.regionScore,
    required super.productScore,
    required super.deliveryScore,
    required super.certificationScore,
    required super.minOrderAmount,
    required super.priceLevel,
    required super.priceNote,
    required super.deliveryAvailable,
    super.deliveryInfo,
    required super.deliverySpeed,
    required super.deliveryFee,
    required super.deliveryRegions,
    required super.serviceRegions,
    required super.supplyProducts,
    super.certifications,
    required super.certificationCount,
    required super.operatingHours,
    required super.qualityRating,
    required super.reliabilityScore,
    super.description,
    required super.strengths,
    required super.weaknesses,
    required super.rank,
    required super.bestCategory,
  });

  factory DistributorComparisonModel.fromJson(Map<String, dynamic> json) {
    return DistributorComparisonModel(
      distributorId: json['distributorId'] as String? ?? '',
      distributorName: json['distributorName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      regionScore: (json['regionScore'] as num?)?.toDouble() ?? 0.0,
      productScore: (json['productScore'] as num?)?.toDouble() ?? 0.0,
      deliveryScore: (json['deliveryScore'] as num?)?.toDouble() ?? 0.0,
      certificationScore:
          (json['certificationScore'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: json['minOrderAmount'] as int? ?? 0,
      priceLevel: json['priceLevel'] as String? ?? 'MEDIUM',
      priceNote: json['priceNote'] as String? ?? '',
      deliveryAvailable: json['deliveryAvailable'] as bool? ?? false,
      deliveryInfo: json['deliveryInfo'] as String?,
      deliverySpeed: json['deliverySpeed'] as String? ?? 'NEXT_DAY',
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      deliveryRegions: json['deliveryRegions'] as String? ?? '',
      serviceRegions: json['serviceRegions'] as String? ?? '',
      supplyProducts: json['supplyProducts'] as String? ?? '',
      certifications: json['certifications'] as String?,
      certificationCount: json['certificationCount'] as int? ?? 0,
      operatingHours: json['operatingHours'] as String? ?? '',
      qualityRating: json['qualityRating'] as String? ?? 'AVERAGE',
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rank: json['rank'] as int? ?? 0,
      bestCategory: json['bestCategory'] as String? ?? 'SERVICE',
    );
  }
}
