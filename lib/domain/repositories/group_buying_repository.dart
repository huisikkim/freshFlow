import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_room.dart';
import '../entities/group_buying_participant.dart';
import '../entities/group_buying_statistics.dart';

abstract class GroupBuyingRepository {
  // Room Management (Distributor)
  Future<Either<Failure, GroupBuyingRoom>> createRoom({
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
  });

  Future<Either<Failure, Map<String, dynamic>>> openRoom({
    required String roomId,
    required String distributorId,
  });

  Future<Either<Failure, Map<String, dynamic>>> closeRoom({
    required String roomId,
    required String distributorId,
  });

  Future<Either<Failure, void>> cancelRoom({
    required String roomId,
    required String distributorId,
    required String reason,
  });

  Future<Either<Failure, List<GroupBuyingRoom>>> getDistributorRooms(
    String distributorId,
  );

  // Room Query (Store)
  Future<Either<Failure, List<GroupBuyingRoom>>> getOpenRooms({
    String? region,
    String? category,
  });

  Future<Either<Failure, GroupBuyingRoom>> getRoomDetail(String roomId);

  Future<Either<Failure, List<GroupBuyingRoom>>> getFeaturedRooms();

  Future<Either<Failure, List<GroupBuyingRoom>>> getDeadlineSoonRooms();

  // Participation (Store)
  Future<Either<Failure, GroupBuyingParticipant>> joinRoom({
    required String roomId,
    required String storeId,
    required int quantity,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryRequest,
  });

  Future<Either<Failure, void>> cancelParticipation({
    required int participantId,
    required String storeId,
    required String reason,
  });

  Future<Either<Failure, List<GroupBuyingParticipant>>> getStoreParticipations(
    String storeId,
  );

  Future<Either<Failure, List<GroupBuyingParticipant>>> getRoomParticipants(
    String roomId,
  );

  // Statistics
  Future<Either<Failure, DistributorStatistics>> getDistributorStatistics(
    String distributorId,
  );

  Future<Either<Failure, StoreStatistics>> getStoreStatistics(String storeId);

  Future<Either<Failure, SystemStatistics>> getSystemStatistics();
}
