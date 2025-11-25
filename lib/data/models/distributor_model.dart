import 'package:fresh_flow/domain/entities/distributor.dart';

class DistributorModel extends Distributor {
  const DistributorModel({
    required super.id,
    required super.distributorId,
    required super.distributorName,
    required super.supplyProducts,
    required super.serviceRegions,
    required super.deliveryAvailable,
    required super.deliveryInfo,
    required super.description,
    required super.certifications,
    required super.minOrderAmount,
    required super.operatingHours,
    required super.phoneNumber,
    required super.email,
    required super.address,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DistributorModel.fromJson(Map<String, dynamic> json) {
    return DistributorModel(
      id: json['id'] as int,
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String,
      supplyProducts: json['supplyProducts'] as String,
      serviceRegions: json['serviceRegions'] as String,
      deliveryAvailable: json['deliveryAvailable'] as bool,
      deliveryInfo: json['deliveryInfo'] as String,
      description: json['description'] as String,
      certifications: json['certifications'] as String,
      minOrderAmount: json['minOrderAmount'] as int,
      operatingHours: json['operatingHours'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distributorName': distributorName,
      'supplyProducts': supplyProducts,
      'serviceRegions': serviceRegions,
      'deliveryAvailable': deliveryAvailable,
      'deliveryInfo': deliveryInfo,
      'description': description,
      'certifications': certifications,
      'minOrderAmount': minOrderAmount,
      'operatingHours': operatingHours,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}
