import 'package:fresh_flow/domain/entities/distributor.dart';

abstract class DistributorRepository {
  Future<Distributor> registerDistributor({
    required String distributorName,
    required String supplyProducts,
    required String serviceRegions,
    required bool deliveryAvailable,
    required String deliveryInfo,
    required String description,
    required String certifications,
    required int minOrderAmount,
    required String operatingHours,
    required String phoneNumber,
    required String email,
    required String address,
  });
  
  Future<Distributor?> getDistributorInfo();
}
