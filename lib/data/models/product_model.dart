import 'package:fresh_flow/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.distributorId,
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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      distributorId: json['distributorId'] as String,
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
