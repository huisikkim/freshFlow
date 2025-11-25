class DistributorRecommendation {
  final String distributorId;
  final String distributorName;
  final double totalScore;
  final double regionScore;
  final double productScore;
  final double deliveryScore;
  final double certificationScore;
  final String matchReason;
  final String supplyProducts;
  final String serviceRegions;
  final bool deliveryAvailable;
  final String? deliveryInfo;
  final String? certifications;
  final int minOrderAmount;
  final String phoneNumber;
  final String email;

  const DistributorRecommendation({
    required this.distributorId,
    required this.distributorName,
    required this.totalScore,
    required this.regionScore,
    required this.productScore,
    required this.deliveryScore,
    required this.certificationScore,
    required this.matchReason,
    required this.supplyProducts,
    required this.serviceRegions,
    required this.deliveryAvailable,
    this.deliveryInfo,
    this.certifications,
    required this.minOrderAmount,
    required this.phoneNumber,
    required this.email,
  });
}
