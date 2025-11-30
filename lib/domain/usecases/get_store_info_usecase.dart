import 'package:fresh_flow/domain/entities/store.dart';
import 'package:fresh_flow/domain/repositories/store_repository.dart';

class GetStoreInfoUseCase {
  final StoreRepository repository;

  GetStoreInfoUseCase(this.repository);

  Future<Store?> execute() async {
    return await repository.getStoreInfo();
  }
}
