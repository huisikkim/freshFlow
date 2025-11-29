import 'package:equatable/equatable.dart';

enum ParticipantStatus {
  joined,
  confirmed,
  orderCreated,
  delivered,
  cancelled,
}

class GroupBuyingParticipant extends Equatable {
  final int id;
  final String storeId;
  final String storeName;
  final String? storeRegion;
  final int quantity;
  final double unitPrice;
  final double totalProductAmount;
  final double deliveryFee;
  final double totalAmount;
  final double savingsAmount;
  final String? deliveryAddress;
  final String? deliveryPhone;
  final String? deliveryRequest;
  final ParticipantStatus status;
  final DateTime joinedAt;

  const GroupBuyingParticipant({
    required this.id,
    required this.storeId,
    required this.storeName,
    this.storeRegion,
    required this.quantity,
    required this.unitPrice,
    required this.totalProductAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.savingsAmount,
    this.deliveryAddress,
    this.deliveryPhone,
    this.deliveryRequest,
    required this.status,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        storeName,
        storeRegion,
        quantity,
        unitPrice,
        totalProductAmount,
        deliveryFee,
        totalAmount,
        savingsAmount,
        deliveryAddress,
        deliveryPhone,
        deliveryRequest,
        status,
        joinedAt,
      ];
}
