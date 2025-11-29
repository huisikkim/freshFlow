import '../../domain/entities/group_buying_participant.dart';

class GroupBuyingParticipantModel extends GroupBuyingParticipant {
  const GroupBuyingParticipantModel({
    required super.id,
    required super.storeId,
    required super.storeName,
    super.storeRegion,
    required super.quantity,
    required super.unitPrice,
    required super.totalProductAmount,
    required super.deliveryFee,
    required super.totalAmount,
    required super.savingsAmount,
    super.deliveryAddress,
    super.deliveryPhone,
    super.deliveryRequest,
    required super.status,
    required super.joinedAt,
  });

  factory GroupBuyingParticipantModel.fromJson(Map<String, dynamic> json) {
    return GroupBuyingParticipantModel(
      id: json['id'] as int,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      storeRegion: json['storeRegion'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalProductAmount: (json['totalProductAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      savingsAmount: (json['savingsAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryPhone: json['deliveryPhone'] as String?,
      deliveryRequest: json['deliveryRequest'] as String?,
      status: _parseParticipantStatus(json['status'] as String),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'storeRegion': storeRegion,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalProductAmount': totalProductAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'savingsAmount': savingsAmount,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'deliveryRequest': deliveryRequest,
      'status': _participantStatusToString(status),
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  static ParticipantStatus _parseParticipantStatus(String status) {
    switch (status) {
      case 'JOINED':
        return ParticipantStatus.joined;
      case 'CONFIRMED':
        return ParticipantStatus.confirmed;
      case 'ORDER_CREATED':
        return ParticipantStatus.orderCreated;
      case 'DELIVERED':
        return ParticipantStatus.delivered;
      case 'CANCELLED':
        return ParticipantStatus.cancelled;
      default:
        return ParticipantStatus.joined;
    }
  }

  static String _participantStatusToString(ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.joined:
        return 'JOINED';
      case ParticipantStatus.confirmed:
        return 'CONFIRMED';
      case ParticipantStatus.orderCreated:
        return 'ORDER_CREATED';
      case ParticipantStatus.delivered:
        return 'DELIVERED';
      case ParticipantStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
