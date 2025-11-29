import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_room.dart';
import '../repositories/group_buying_repository.dart';

class GetDistributorRooms {
  final GroupBuyingRepository repository;

  GetDistributorRooms(this.repository);

  Future<Either<Failure, List<GroupBuyingRoom>>> call(
    String distributorId,
  ) async {
    return await repository.getDistributorRooms(distributorId);
  }
}
