import 'package:fresh_flow/domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.storeId,
    required super.storeName,
    required super.ownerName,
    required super.phoneNumber,
    required super.address,
    required super.businessType,
    required super.region,
    required super.mainProducts,
    required super.description,
    required super.employeeCount,
    required super.operatingHours,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      ownerName: json['ownerName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      businessType: json['businessType'] as String,
      region: json['region'] as String,
      mainProducts: json['mainProducts'] as String,
      description: json['description'] as String,
      employeeCount: json['employeeCount'] as int,
      operatingHours: json['operatingHours'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'businessType': businessType,
      'region': region,
      'mainProducts': mainProducts,
      'description': description,
      'employeeCount': employeeCount,
      'operatingHours': operatingHours,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
