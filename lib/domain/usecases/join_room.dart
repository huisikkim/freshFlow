import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_participant.dart';
import '../repositories/group_buying_repository.dart';

class JoinRoom {
  final GroupBuyingRepository repository;

  JoinRoom(this.repository);

  Future<Either<Failure, GroupBuyingParticipant>> call({
    required String roomId,
    required String storeId,
    required int quantity,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryRequest,
  }) async {
    return await repository.joinRoom(
      roomId: roomId,
      storeId: storeId,
      quantity: quantity,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryRequest: deliveryRequest,
    );
  }
}
