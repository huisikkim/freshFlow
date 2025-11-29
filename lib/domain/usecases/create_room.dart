import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_room.dart';
import '../repositories/group_buying_repository.dart';

class CreateRoom {
  final GroupBuyingRepository repository;

  CreateRoom(this.repository);

  Future<Either<Failure, GroupBuyingRoom>> call({
    required String roomTitle,
    required String distributorId,
    required String distributorName,
    required int productId,
    required double discountRate,
    required int availableStock,
    required int targetQuantity,
    required int minOrderPerStore,
    required int minParticipants,
    required String region,
    required double deliveryFee,
    required String deliveryFeeType,
    required int durationHours,
    int? maxOrderPerStore,
    int? maxParticipants,
    String? expectedDeliveryDate,
    String? description,
    String? specialNote,
    bool? featured,
  }) async {
    return await repository.createRoom(
      roomTitle: roomTitle,
      distributorId: distributorId,
      distributorName: distributorName,
      productId: productId,
      discountRate: discountRate,
      availableStock: availableStock,
      targetQuantity: targetQuantity,
      minOrderPerStore: minOrderPerStore,
      minParticipants: minParticipants,
      region: region,
      deliveryFee: deliveryFee,
      deliveryFeeType: deliveryFeeType,
      durationHours: durationHours,
      maxOrderPerStore: maxOrderPerStore,
      maxParticipants: maxParticipants,
      expectedDeliveryDate: expectedDeliveryDate,
      description: description,
      specialNote: specialNote,
      featured: featured,
    );
  }
}
