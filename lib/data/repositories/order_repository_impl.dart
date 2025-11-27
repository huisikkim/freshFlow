import 'package:dartz/dartz.dart';
import 'package:fresh_flow/core/errors/exceptions.dart';
import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/data/datasources/order_remote_data_source.dart';
import 'package:fresh_flow/domain/entities/order.dart' as entities;
import 'package:fresh_flow/domain/repositories/order_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, entities.Order>> createOrder({
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      if (user.storeId == null) {
        return Left(ServerFailure(message: 'Store ID not found. Please login again.'));
      }

      print('🔑 토큰 확인: ${user.accessToken.substring(0, 20)}...');
      print('🏪 StoreId: ${user.storeId}');
      print('🏪 StoreId 타입: ${user.storeId.runtimeType}');
      print('👤 Username: ${user.username}');
      print('🏢 UserType: ${user.userType}');
      print('📦 주문 아이템 수: ${items.length}');
      print('📦 DistributorId: $distributorId');

      final order = await remoteDataSource.createOrder(
        token: user.accessToken,
        storeId: user.storeId!,
        distributorId: distributorId,
        deliveryAddress: deliveryAddress,
        deliveryPhone: deliveryPhone,
        deliveryRequest: deliveryRequest,
        desiredDeliveryDate: desiredDeliveryDate,
        items: items,
      );
      return Right(order);
    } on UnauthorizedException {
      print('❌ 인증 오류');
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      print('❌ 서버 예외: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('❌ 예상치 못한 오류: $e');
      print('❌ 오류 타입: ${e.runtimeType}');
      return Left(ServerFailure(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<entities.Order>>> getOrders() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      if (user.storeId == null) {
        return Left(ServerFailure(message: 'Store ID not found. Please login again.'));
      }

      final orders = await remoteDataSource.getOrders(user.accessToken, user.storeId!);
      return Right(orders);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<entities.Order>>> getDistributorOrders() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      if (user.distributorId == null) {
        return Left(ServerFailure(message: 'Distributor ID not found. Please login again.'));
      }

      final orders = await remoteDataSource.getDistributorOrders(
        user.accessToken,
        user.distributorId!,
      );
      return Right(orders);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, entities.Order>> getOrderById(String orderId) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      if (user.storeId == null) {
        return Left(ServerFailure(message: 'Store ID not found. Please login again.'));
      }

      final order = await remoteDataSource.getOrderById(user.accessToken, user.storeId!, orderId);
      return Right(order);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, entities.Order>> cancelOrder(String orderId) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      if (user.storeId == null) {
        return Left(ServerFailure(message: 'Store ID not found. Please login again.'));
      }

      final order = await remoteDataSource.cancelOrder(user.accessToken, user.storeId!, orderId);
      return Right(order);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, entities.Order>> confirmPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        return Left(UnauthorizedFailure());
      }

      print('💳 결제 승인 시작');
      print('  - orderId: $orderId');
      print('  - paymentKey: $paymentKey');
      print('  - amount: $amount');

      final order = await remoteDataSource.confirmPayment(
        token: user.accessToken,
        orderId: orderId,
        paymentKey: paymentKey,
        amount: amount,
      );
      
      print('✅ 결제 승인 완료');
      return Right(order);
    } on UnauthorizedException {
      print('❌ 인증 오류');
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      print('❌ 서버 예외: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('❌ 예상치 못한 오류: $e');
      return Left(ServerFailure(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }
}
