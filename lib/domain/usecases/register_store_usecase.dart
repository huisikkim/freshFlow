import 'package:fresh_flow/domain/entities/store.dart';
import 'package:fresh_flow/domain/repositories/store_repository.dart';

class RegisterStoreUseCase {
  final StoreRepository repository;

  RegisterStoreUseCase(this.repository);

  Future<Store> execute({
    required String storeName,
    required String businessType,
    required String region,
    required String mainProducts,
    required String description,
    required int employeeCount,
    required String operatingHours,
    required String phoneNumber,
    required String address,
  }) async {
    return await repository.registerStore(
      storeName: storeName,
      businessType: businessType,
      region: region,
      mainProducts: mainProducts,
      description: description,
      employeeCount: employeeCount,
      operatingHours: operatingHours,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}
