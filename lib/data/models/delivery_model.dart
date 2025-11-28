import 'package:fresh_flow/domain/entities/delivery.dart';

class DeliveryModel extends Delivery {
  DeliveryModel({
    required super.id,
    required super.orderId,
    required super.status,
    super.deliveryType,
    super.trackingNumber,
    super.courierCompany,
    super.driverName,
    super.driverPhone,
    super.vehicleNumber,
    super.estimatedDeliveryDate,
    super.shippedAt,
    super.deliveredAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'].toString(),
      orderId: json['orderId'] as int,
      status: DeliveryStatusExtension.fromCode(json['status'] as String),
      deliveryType: json['deliveryType'] != null
          ? DeliveryTypeExtension.fromCode(json['deliveryType'] as String)
          : null,
      trackingNumber: json['trackingNumber'] as String?,
      courierCompany: json['courierCompany'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'] as String)
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status.code,
      'deliveryType': deliveryType?.code,
      'trackingNumber': trackingNumber,
      'courierCompany': courierCompany,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
