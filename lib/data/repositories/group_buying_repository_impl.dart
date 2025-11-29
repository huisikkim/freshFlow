import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/group_buying_room.dart';
import '../../domain/entities/group_buying_participant.dart';
import '../../domain/entities/group_buying_statistics.dart';
import '../../domain/repositories/group_buying_repository.dart';
import '../datasources/group_buying_remote_data_source.dart';

class GroupBuyingRepositoryImpl implements GroupBuyingRepository {
  final GroupBuyingRemoteDataSource remoteDataSource;

  GroupBuyingRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final roomData = {
        'roomTitle': roomTitle,
        'distributorId': distributorId,
        'distributorName': distributorName,
        'productId': productId,
        'discountRate': discountRate,
        'availableStock': availableStock,
        'targetQuantity': targetQuantity,
        'minOrderPerStore': minOrderPerStore,
        'minParticipants': minParticipants,
        'region': region,
        'deliveryFee': deliveryFee,
        'deliveryFeeType': deliveryFeeType,
        'durationHours': durationHours,
        if (maxOrderPerStore != null) 'maxOrderPerStore': maxOrderPerStore,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
        if (expectedDeliveryDate != null) 'expectedDeliveryDate': expectedDeliveryDate,
        if (description != null) 'description': description,
        if (specialNote != null) 'specialNote': specialNote,
        if (featured != null) 'featured': featured,
      };
      final room = await remoteDataSource.createRoom(roomData);
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> openRoom({
    required String roomId,
    required String distributorId,
  }) async {
    try {
      final result = await remoteDataSource.openRoom(roomId, distributorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> closeRoom({
    required String roomId,
    required String distributorId,
  }) async {
    try {
      final result = await remoteDataSource.closeRoom(roomId, distributorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRoom({
    required String roomId,
    required String distributorId,
    required String reason,
  }) async {
    try {
      await remoteDataSource.cancelRoom(roomId, distributorId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingRoom>>> getDistributorRooms(
    String distributorId,
  ) async {
    try {
      final rooms = await remoteDataSource.getDistributorRooms(distributorId);
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingRoom>>> getOpenRooms({
    String? region,
    String? category,
  }) async {
    try {
      final rooms = await remoteDataSource.getOpenRooms(
        region: region,
        category: category,
      );
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupBuyingRoom>> getRoomDetail(String roomId) async {
    try {
      final room = await remoteDataSource.getRoomDetail(roomId);
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingRoom>>> getFeaturedRooms() async {
    try {
      final rooms = await remoteDataSource.getFeaturedRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingRoom>>> getDeadlineSoonRooms() async {
    try {
      final rooms = await remoteDataSource.getDeadlineSoonRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupBuyingParticipant>> joinRoom({
    required String roomId,
    required String storeId,
    required int quantity,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryRequest,
  }) async {
    try {
      final participantData = {
        'roomId': roomId,
        'storeId': storeId,
        'quantity': quantity,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (deliveryPhone != null) 'deliveryPhone': deliveryPhone,
        if (deliveryRequest != null) 'deliveryRequest': deliveryRequest,
      };
      final participant = await remoteDataSource.joinRoom(participantData);
      return Right(participant);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelParticipation({
    required int participantId,
    required String storeId,
    required String reason,
  }) async {
    try {
      await remoteDataSource.cancelParticipation(participantId, storeId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingParticipant>>> getStoreParticipations(
    String storeId,
  ) async {
    try {
      final participants = await remoteDataSource.getStoreParticipations(storeId);
      return Right(participants);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBuyingParticipant>>> getRoomParticipants(
    String roomId,
  ) async {
    try {
      final participants = await remoteDataSource.getRoomParticipants(roomId);
      return Right(participants);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DistributorStatistics>> getDistributorStatistics(
    String distributorId,
  ) async {
    try {
      final stats = await remoteDataSource.getDistributorStatistics(distributorId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreStatistics>> getStoreStatistics(
    String storeId,
  ) async {
    try {
      final stats = await remoteDataSource.getStoreStatistics(storeId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SystemStatistics>> getSystemStatistics() async {
    try {
      final stats = await remoteDataSource.getSystemStatistics();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
