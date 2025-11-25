class Distributor {
  final int id;
  final String distributorId;
  final String distributorName;
  final String supplyProducts;
  final String serviceRegions;
  final bool deliveryAvailable;
  final String deliveryInfo;
  final String description;
  final String certifications;
  final int minOrderAmount;
  final String operatingHours;
  final String phoneNumber;
  final String email;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Distributor({
    required this.id,
    required this.distributorId,
    required this.distributorName,
    required this.supplyProducts,
    required this.serviceRegions,
    required this.deliveryAvailable,
    required this.deliveryInfo,
    required this.description,
    required this.certifications,
    required this.minOrderAmount,
    required this.operatingHours,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
