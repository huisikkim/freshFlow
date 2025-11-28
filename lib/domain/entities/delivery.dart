class Delivery {
  final String id;
  final int orderId; // DB의 Long ID
  final DeliveryStatus status;
  final DeliveryType? deliveryType;
  final String? trackingNumber;
  final String? courierCompany;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    this.deliveryType,
    this.trackingNumber,
    this.courierCompany,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.estimatedDeliveryDate,
    this.shippedAt,
    this.deliveredAt,
    required this.createdAt,
    this.updatedAt,
  });
}

enum DeliveryStatus {
  preparing,  // 상품준비중
  shipped,    // 배송중
  delivered,  // 배송완료
}

enum DeliveryType {
  courier,  // 택배 배송
  direct,   // 직접 배송
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.preparing:
        return '상품준비중';
      case DeliveryStatus.shipped:
        return '배송중';
      case DeliveryStatus.delivered:
        return '배송완료';
    }
  }

  String get code {
    switch (this) {
      case DeliveryStatus.preparing:
        return 'PREPARING';
      case DeliveryStatus.shipped:
        return 'SHIPPED';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
    }
  }

  static DeliveryStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'PREPARING':
        return DeliveryStatus.preparing;
      case 'SHIPPED':
        return DeliveryStatus.shipped;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      default:
        return DeliveryStatus.preparing;
    }
  }
}

extension DeliveryTypeExtension on DeliveryType {
  String get displayName {
    switch (this) {
      case DeliveryType.courier:
        return '택배 배송';
      case DeliveryType.direct:
        return '직접 배송';
    }
  }

  String get code {
    switch (this) {
      case DeliveryType.courier:
        return 'COURIER';
      case DeliveryType.direct:
        return 'DIRECT';
    }
  }

  static DeliveryType fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'COURIER':
        return DeliveryType.courier;
      case 'DIRECT':
        return DeliveryType.direct;
      default:
        return DeliveryType.courier;
    }
  }
}
