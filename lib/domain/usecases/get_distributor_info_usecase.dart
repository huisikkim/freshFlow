import 'package:fresh_flow/domain/entities/distributor.dart';
import 'package:fresh_flow/domain/repositories/distributor_repository.dart';

class GetDistributorInfoUseCase {
  final DistributorRepository repository;

  GetDistributorInfoUseCase(this.repository);

  Future<Distributor?> execute() async {
    return await repository.getDistributorInfo();
  }
}
