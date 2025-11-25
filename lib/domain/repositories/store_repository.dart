import 'package:fresh_flow/domain/entities/store.dart';

abstract class StoreRepository {
  Future<Store> registerStore({
    required String storeName,
    required String businessType,
    required String region,
    required String mainProducts,
    required String description,
    required int employeeCount,
    required String operatingHours,
    required String phoneNumber,
    required String address,
  });
}
