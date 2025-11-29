import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/group_buying_repository.dart';

class OpenRoom {
  final GroupBuyingRepository repository;

  OpenRoom(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String roomId,
    required String distributorId,
  }) async {
    return await repository.openRoom(
      roomId: roomId,
      distributorId: distributorId,
    );
  }
}
