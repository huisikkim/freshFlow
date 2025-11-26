class DistributorComparison {
  final String distributorId;
  final String distributorName;
  final String phoneNumber;
  final String email;
  final double totalScore;
  final double regionScore;
  final double productScore;
  final double deliveryScore;
  final double certificationScore;
  final int minOrderAmount;
  final String priceLevel; // LOW, MEDIUM, HIGH
  final String priceNote;
  final bool deliveryAvailable;
  final String? deliveryInfo;
  final String deliverySpeed; // SAME_DAY, NEXT_DAY, TWO_TO_THREE_DAYS, OVER_THREE_DAYS
  final int deliveryFee;
  final String deliveryRegions;
  final String serviceRegions;
  final String supplyProducts;
  final String? certifications;
  final int certificationCount;
  final String operatingHours;
  final String qualityRating; // EXCELLENT, GOOD, AVERAGE, BELOW_AVERAGE
  final double reliabilityScore;
  final String? description;
  final List<String> strengths;
  final List<String> weaknesses;
  final int rank;
  final String bestCategory; // PRICE, DELIVERY, QUALITY, SERVICE, CERTIFICATION

  const DistributorComparison({
    required this.distributorId,
    required this.distributorName,
    required this.phoneNumber,
    required this.email,
    required this.totalScore,
    required this.regionScore,
    required this.productScore,
    required this.deliveryScore,
    required this.certificationScore,
    required this.minOrderAmount,
    required this.priceLevel,
    required this.priceNote,
    required this.deliveryAvailable,
    this.deliveryInfo,
    required this.deliverySpeed,
    required this.deliveryFee,
    required this.deliveryRegions,
    required this.serviceRegions,
    required this.supplyProducts,
    this.certifications,
    required this.certificationCount,
    required this.operatingHours,
    required this.qualityRating,
    required this.reliabilityScore,
    this.description,
    required this.strengths,
    required this.weaknesses,
    required this.rank,
    required this.bestCategory,
  });
}
