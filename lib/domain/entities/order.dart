class Order {
  final String id; // orderNumber (ORD-20251127-155507-742)
  final int? dbId; // DB의 실제 Long ID
  final String storeId;
  final String distributorId;
  final String distributorName;
  final List<OrderItem> items;
  final int totalAmount;
  final String deliveryAddress;
  final String deliveryPhone;
  final String? deliveryRequest;
  final DateTime? desiredDeliveryDate;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    this.dbId,
    required this.storeId,
    required this.distributorId,
    required this.distributorName,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.deliveryRequest,
    this.desiredDeliveryDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  bool get canCancel {
    return status == OrderStatus.pending ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.preparing;
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final int unitPrice;
  final int subtotal;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
    this.imageUrl,
  });
}

enum OrderStatus {
  pending,    // 주문대기
  confirmed,  // 주문확정
  preparing,  // 상품준비중
  shipped,    // 배송중
  delivered,  // 배송완료
  cancelled,  // 주문취소
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return '주문대기';
      case OrderStatus.confirmed:
        return '주문확정';
      case OrderStatus.preparing:
        return '상품준비중';
      case OrderStatus.shipped:
        return '배송중';
      case OrderStatus.delivered:
        return '배송완료';
      case OrderStatus.cancelled:
        return '주문취소';
    }
  }

  String get code {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
