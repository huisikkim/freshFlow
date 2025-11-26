import 'package:fresh_flow/domain/entities/product.dart';

class DeliveryInfoModel extends DeliveryInfo {
  const DeliveryInfoModel({
    required super.deliveryType,
    required super.deliveryFee,
    required super.freeDeliveryThreshold,
    required super.deliveryFeeInfo,
    required super.deliveryRegions,
    required super.deliveryDays,
    required super.deliveryTimeSlots,
    required super.estimatedDeliveryDays,
    required super.estimatedDeliveryInfo,
    required super.packagingType,
    required super.isFragile,
    required super.requiresRefrigeration,
    super.specialInstructions,
  });

  factory DeliveryInfoModel.fromJson(Map<String, dynamic> json) {
    return DeliveryInfoModel(
      deliveryType: json['deliveryType'] as String,
      deliveryFee: json['deliveryFee'] as int,
      freeDeliveryThreshold: json['freeDeliveryThreshold'] as int,
      deliveryFeeInfo: json['deliveryFeeInfo'] as String,
      deliveryRegions: json['deliveryRegions'] as String,
      deliveryDays: json['deliveryDays'] as String,
      deliveryTimeSlots: json['deliveryTimeSlots'] as String,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] as int,
      estimatedDeliveryInfo: json['estimatedDeliveryInfo'] as String,
      packagingType: json['packagingType'] as String,
      isFragile: json['isFragile'] as bool,
      requiresRefrigeration: json['requiresRefrigeration'] as bool,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryType': deliveryType,
      'deliveryFee': deliveryFee,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'deliveryRegions': deliveryRegions,
      'deliveryDays': deliveryDays,
      'deliveryTimeSlots': deliveryTimeSlots,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'packagingType': packagingType,
      'isFragile': isFragile,
      'requiresRefrigeration': requiresRefrigeration,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
    };
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.distributorId,
    super.distributorName,
    required super.productName,
    required super.category,
    required super.description,
    required super.unitPrice,
    required super.unit,
    required super.stockQuantity,
    required super.origin,
    required super.brand,
    super.imageUrl,
    required super.isAvailable,
    required super.minOrderQuantity,
    required super.maxOrderQuantity,
    super.certifications,
    required super.createdAt,
    required super.updatedAt,
    super.priceInfo,
    super.hasDiscount,
    super.stockStatus,
    super.orderLimitInfo,
    super.deliveryInfo,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String?,
      productName: json['productName'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      unitPrice: json['unitPrice'] as int,
      unit: json['unit'] as String,
      stockQuantity: json['stockQuantity'] as int,
      origin: json['origin'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool,
      minOrderQuantity: json['minOrderQuantity'] as int,
      maxOrderQuantity: json['maxOrderQuantity'] as int,
      certifications: json['certifications'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      priceInfo: json['priceInfo'] as String?,
      hasDiscount: json['hasDiscount'] as bool?,
      stockStatus: json['stockStatus'] as String?,
      orderLimitInfo: json['orderLimitInfo'] as String?,
      deliveryInfo: json['deliveryInfo'] != null
          ? DeliveryInfoModel.fromJson(json['deliveryInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'category': category,
      'description': description,
      'unitPrice': unitPrice,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'origin': origin,
      'brand': brand,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      if (certifications != null) 'certifications': certifications,
    };
  }
}
