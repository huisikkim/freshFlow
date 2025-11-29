import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_room.dart';
import '../repositories/group_buying_repository.dart';

class GetOpenRooms {
  final GroupBuyingRepository repository;

  GetOpenRooms(this.repository);

  Future<Either<Failure, List<GroupBuyingRoom>>> call({
    String? region,
    String? category,
  }) async {
    return await repository.getOpenRooms(region: region, category: category);
  }
}
