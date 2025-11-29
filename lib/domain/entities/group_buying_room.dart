import 'package:equatable/equatable.dart';

enum RoomStatus {
  waiting,
  open,
  closedSuccess,
  closedFailed,
  orderCreated,
  completed,
  cancelled,
}

enum DeliveryFeeType {
  free,
  fixed,
  shared,
}

class GroupBuyingRoom extends Equatable {
  final int id;
  final String roomId;
  final String roomTitle;
  final String distributorId;
  final String distributorName;
  final int productId;
  final String productName;
  final String? category;
  final String? unit;
  final String? origin;
  final String? productDescription;
  final String? imageUrl;
  final double originalPrice;
  final double discountRate;
  final double discountedPrice;
  final double savingsPerUnit;
  final int availableStock;
  final int targetQuantity;
  final int currentQuantity;
  final int minOrderPerStore;
  final int? maxOrderPerStore;
  final int minParticipants;
  final int? maxParticipants;
  final int currentParticipants;
  final double achievementRate;
  final double? stockRemainRate;
  final String region;
  final double deliveryFee;
  final double? deliveryFeePerStore;
  final DeliveryFeeType deliveryFeeType;
  final DateTime? expectedDeliveryDate;
  final DateTime? startTime;
  final DateTime? deadline;
  final int durationHours;
  final int? remainingMinutes;
  final RoomStatus status;
  final DateTime? openedAt;
  final String? description;
  final String? specialNote;
  final bool featured;
  final int? viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupBuyingRoom({
    required this.id,
    required this.roomId,
    required this.roomTitle,
    required this.distributorId,
    required this.distributorName,
    required this.productId,
    required this.productName,
    this.category,
    this.unit,
    this.origin,
    this.productDescription,
    this.imageUrl,
    required this.originalPrice,
    required this.discountRate,
    required this.discountedPrice,
    required this.savingsPerUnit,
    required this.availableStock,
    required this.targetQuantity,
    required this.currentQuantity,
    required this.minOrderPerStore,
    this.maxOrderPerStore,
    required this.minParticipants,
    this.maxParticipants,
    required this.currentParticipants,
    required this.achievementRate,
    this.stockRemainRate,
    required this.region,
    required this.deliveryFee,
    this.deliveryFeePerStore,
    required this.deliveryFeeType,
    this.expectedDeliveryDate,
    this.startTime,
    this.deadline,
    required this.durationHours,
    this.remainingMinutes,
    required this.status,
    this.openedAt,
    this.description,
    this.specialNote,
    required this.featured,
    this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        roomTitle,
        distributorId,
        distributorName,
        productId,
        productName,
        category,
        unit,
        origin,
        productDescription,
        imageUrl,
        originalPrice,
        discountRate,
        discountedPrice,
        savingsPerUnit,
        availableStock,
        targetQuantity,
        currentQuantity,
        minOrderPerStore,
        maxOrderPerStore,
        minParticipants,
        maxParticipants,
        currentParticipants,
        achievementRate,
        stockRemainRate,
        region,
        deliveryFee,
        deliveryFeePerStore,
        deliveryFeeType,
        expectedDeliveryDate,
        startTime,
        deadline,
        durationHours,
        remainingMinutes,
        status,
        openedAt,
        description,
        specialNote,
        featured,
        viewCount,
        createdAt,
        updatedAt,
      ];
}
