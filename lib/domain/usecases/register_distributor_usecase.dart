import 'package:fresh_flow/domain/entities/distributor.dart';
import 'package:fresh_flow/domain/repositories/distributor_repository.dart';

class RegisterDistributorUseCase {
  final DistributorRepository repository;

  RegisterDistributorUseCase(this.repository);

  Future<Distributor> execute({
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
  }) async {
    return await repository.registerDistributor(
      distributorName: distributorName,
      supplyProducts: supplyProducts,
      serviceRegions: serviceRegions,
      deliveryAvailable: deliveryAvailable,
      deliveryInfo: deliveryInfo,
      description: description,
      certifications: certifications,
      minOrderAmount: minOrderAmount,
      operatingHours: operatingHours,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
    );
  }
}
