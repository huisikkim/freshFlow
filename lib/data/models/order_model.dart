import 'package:fresh_flow/domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.storeId,
    required super.distributorId,
    required super.distributorName,
    required super.items,
    required super.totalAmount,
    required super.deliveryAddress,
    required super.deliveryPhone,
    super.deliveryRequest,
    super.desiredDeliveryDate,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),  // int를 String으로 변환
      storeId: json['storeId'] as String,
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String? ?? json['distributorId'] as String,  // 없으면 distributorId 사용
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'] as int,
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryPhone: json['deliveryPhone'] as String,
      deliveryRequest: json['deliveryRequest'] as String?,
      desiredDeliveryDate: json['desiredDeliveryDate'] != null
          ? DateTime.parse(json['desiredDeliveryDate'] as String)
          : null,
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['orderedAt'] as String),  // 서버는 'orderedAt' 사용
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'deliveryRequest': deliveryRequest,
      'desiredDeliveryDate': desiredDeliveryDate?.toIso8601String(),
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'SHIPPED':
        return OrderStatus.shipped;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemModel extends OrderItem {
  OrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unit,
    required super.unitPrice,
    required super.subtotal,
    super.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'].toString(),  // int를 String으로 변환
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      unitPrice: json['unitPrice'] as int,
      subtotal: json['subtotal'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
    };
  }
}
