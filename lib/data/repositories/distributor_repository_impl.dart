import 'package:fresh_flow/domain/entities/distributor.dart';
import 'package:fresh_flow/domain/repositories/distributor_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/distributor_remote_datasource.dart';

class DistributorRepositoryImpl implements DistributorRepository {
  final DistributorRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  DistributorRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
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
  }) async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    return await remoteDataSource.registerDistributor(
      token: user.accessToken,
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
