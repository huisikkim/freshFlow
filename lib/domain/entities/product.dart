class DeliveryInfo {
  final String deliveryType;
  final int deliveryFee;
  final int freeDeliveryThreshold;
  final String deliveryFeeInfo;
  final String deliveryRegions;
  final String deliveryDays;
  final String deliveryTimeSlots;
  final int estimatedDeliveryDays;
  final String estimatedDeliveryInfo;
  final String packagingType;
  final bool isFragile;
  final bool requiresRefrigeration;
  final String? specialInstructions;

  const DeliveryInfo({
    required this.deliveryType,
    required this.deliveryFee,
    required this.freeDeliveryThreshold,
    required this.deliveryFeeInfo,
    required this.deliveryRegions,
    required this.deliveryDays,
    required this.deliveryTimeSlots,
    required this.estimatedDeliveryDays,
    required this.estimatedDeliveryInfo,
    required this.packagingType,
    required this.isFragile,
    required this.requiresRefrigeration,
    this.specialInstructions,
  });
}

class Product {
  final int id;
  final String distributorId;
  final String? distributorName;
  final String productName;
  final String category;
  final String description;
  final int unitPrice;
  final String unit;
  final int stockQuantity;
  final String origin;
  final String brand;
  final String? imageUrl;
  final bool isAvailable;
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final String? certifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 상세 정보 필드 (7.14 API용)
  final String? priceInfo;
  final bool? hasDiscount;
  final String? stockStatus;
  final String? orderLimitInfo;
  final DeliveryInfo? deliveryInfo;

  const Product({
    required this.id,
    required this.distributorId,
    this.distributorName,
    required this.productName,
    required this.category,
    required this.description,
    required this.unitPrice,
    required this.unit,
    required this.stockQuantity,
    required this.origin,
    required this.brand,
    this.imageUrl,
    required this.isAvailable,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    this.certifications,
    required this.createdAt,
    required this.updatedAt,
    this.priceInfo,
    this.hasDiscount,
    this.stockStatus,
    this.orderLimitInfo,
    this.deliveryInfo,
  });
}
