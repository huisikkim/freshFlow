class Store {
  final int id;
  final String storeId;
  final String storeName;
  final String ownerName;
  final String phoneNumber;
  final String address;
  final String businessType;
  final String region;
  final String mainProducts;
  final String description;
  final int employeeCount;
  final String operatingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.ownerName,
    required this.phoneNumber,
    required this.address,
    required this.businessType,
    required this.region,
    required this.mainProducts,
    required this.description,
    required this.employeeCount,
    required this.operatingHours,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
