import '../../domain/entities/group_buying_room.dart';

class GroupBuyingRoomModel extends GroupBuyingRoom {
  const GroupBuyingRoomModel({
    required super.id,
    required super.roomId,
    required super.roomTitle,
    required super.distributorId,
    required super.distributorName,
    required super.productId,
    required super.productName,
    super.category,
    super.unit,
    super.origin,
    super.productDescription,
    super.imageUrl,
    required super.originalPrice,
    required super.discountRate,
    required super.discountedPrice,
    required super.savingsPerUnit,
    required super.availableStock,
    required super.targetQuantity,
    required super.currentQuantity,
    required super.minOrderPerStore,
    super.maxOrderPerStore,
    required super.minParticipants,
    super.maxParticipants,
    required super.currentParticipants,
    required super.achievementRate,
    super.stockRemainRate,
    required super.region,
    required super.deliveryFee,
    super.deliveryFeePerStore,
    required super.deliveryFeeType,
    super.expectedDeliveryDate,
    super.startTime,
    super.deadline,
    required super.durationHours,
    super.remainingMinutes,
    required super.status,
    super.openedAt,
    super.description,
    super.specialNote,
    required super.featured,
    super.viewCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupBuyingRoomModel.fromJson(Map<String, dynamic> json) {
    return GroupBuyingRoomModel(
      id: json['id'] as int,
      roomId: json['roomId'] as String,
      roomTitle: json['roomTitle'] as String,
      distributorId: json['distributorId'] as String,
      distributorName: json['distributorName'] as String,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      origin: json['origin'] as String?,
      productDescription: json['productDescription'] as String?,
      imageUrl: json['imageUrl'] as String?,
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
      savingsPerUnit: (json['savingsPerUnit'] as num).toDouble(),
      availableStock: json['availableStock'] as int,
      targetQuantity: json['targetQuantity'] as int,
      currentQuantity: json['currentQuantity'] as int,
      minOrderPerStore: json['minOrderPerStore'] as int,
      maxOrderPerStore: json['maxOrderPerStore'] as int?,
      minParticipants: json['minParticipants'] as int,
      maxParticipants: json['maxParticipants'] as int?,
      currentParticipants: json['currentParticipants'] as int,
      achievementRate: (json['achievementRate'] as num).toDouble(),
      stockRemainRate: json['stockRemainRate'] != null
          ? (json['stockRemainRate'] as num).toDouble()
          : null,
      region: json['region'] as String,
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      deliveryFeePerStore: json['deliveryFeePerStore'] != null
          ? (json['deliveryFeePerStore'] as num).toDouble()
          : null,
      deliveryFeeType: _parseDeliveryFeeType(json['deliveryFeeType'] as String),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'] as String)
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      durationHours: json['durationHours'] as int,
      remainingMinutes: json['remainingMinutes'] as int?,
      status: _parseRoomStatus(json['status'] as String),
      openedAt: json['openedAt'] != null
          ? DateTime.parse(json['openedAt'] as String)
          : null,
      description: json['description'] as String?,
      specialNote: json['specialNote'] as String?,
      featured: json['featured'] as bool? ?? false,
      viewCount: json['viewCount'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomTitle': roomTitle,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'productId': productId,
      'productName': productName,
      'category': category,
      'unit': unit,
      'origin': origin,
      'productDescription': productDescription,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'discountRate': discountRate,
      'discountedPrice': discountedPrice,
      'savingsPerUnit': savingsPerUnit,
      'availableStock': availableStock,
      'targetQuantity': targetQuantity,
      'currentQuantity': currentQuantity,
      'minOrderPerStore': minOrderPerStore,
      'maxOrderPerStore': maxOrderPerStore,
      'minParticipants': minParticipants,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'achievementRate': achievementRate,
      'stockRemainRate': stockRemainRate,
      'region': region,
      'deliveryFee': deliveryFee,
      'deliveryFeePerStore': deliveryFeePerStore,
      'deliveryFeeType': _deliveryFeeTypeToString(deliveryFeeType),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'durationHours': durationHours,
      'remainingMinutes': remainingMinutes,
      'status': _roomStatusToString(status),
      'openedAt': openedAt?.toIso8601String(),
      'description': description,
      'specialNote': specialNote,
      'featured': featured,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RoomStatus _parseRoomStatus(String status) {
    switch (status) {
      case 'WAITING':
        return RoomStatus.waiting;
      case 'OPEN':
        return RoomStatus.open;
      case 'CLOSED_SUCCESS':
        return RoomStatus.closedSuccess;
      case 'CLOSED_FAILED':
        return RoomStatus.closedFailed;
      case 'ORDER_CREATED':
        return RoomStatus.orderCreated;
      case 'COMPLETED':
        return RoomStatus.completed;
      case 'CANCELLED':
        return RoomStatus.cancelled;
      default:
        return RoomStatus.waiting;
    }
  }

  static String _roomStatusToString(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'WAITING';
      case RoomStatus.open:
        return 'OPEN';
      case RoomStatus.closedSuccess:
        return 'CLOSED_SUCCESS';
      case RoomStatus.closedFailed:
        return 'CLOSED_FAILED';
      case RoomStatus.orderCreated:
        return 'ORDER_CREATED';
      case RoomStatus.completed:
        return 'COMPLETED';
      case RoomStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static DeliveryFeeType _parseDeliveryFeeType(String type) {
    switch (type) {
      case 'FREE':
        return DeliveryFeeType.free;
      case 'FIXED':
        return DeliveryFeeType.fixed;
      case 'SHARED':
        return DeliveryFeeType.shared;
      default:
        return DeliveryFeeType.fixed;
    }
  }

  static String _deliveryFeeTypeToString(DeliveryFeeType type) {
    switch (type) {
      case DeliveryFeeType.free:
        return 'FREE';
      case DeliveryFeeType.fixed:
        return 'FIXED';
      case DeliveryFeeType.shared:
        return 'SHARED';
    }
  }
}
