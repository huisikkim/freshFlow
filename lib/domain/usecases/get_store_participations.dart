import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/group_buying_participant.dart';
import '../repositories/group_buying_repository.dart';

class GetStoreParticipations {
  final GroupBuyingRepository repository;

  GetStoreParticipations(this.repository);

  Future<Either<Failure, List<GroupBuyingParticipant>>> call(
    String storeId,
  ) async {
    return await repository.getStoreParticipations(storeId);
  }
}
