import 'package:fresh_flow/domain/entities/store.dart';
import 'package:fresh_flow/domain/repositories/store_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  StoreRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
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
  }) async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    return await remoteDataSource.registerStore(
      token: user.accessToken,
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

  @override
  Future<Store?> getStoreInfo() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    return await remoteDataSource.getStoreInfo(token: user.accessToken);
  }
}
