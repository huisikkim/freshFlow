import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_room.dart';
import '../repositories/group_buying_repository.dart';

class GetRoomDetail {
  final GroupBuyingRepository repository;

  GetRoomDetail(this.repository);

  Future<Either<Failure, GroupBuyingRoom>> call(String roomId) async {
    return await repository.getRoomDetail(roomId);
  }
}
