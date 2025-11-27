import 'package:dartz/dartz.dart';
import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/domain/entities/order.dart' as entities;
import 'package:fresh_flow/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, entities.Order>> call({
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    return await repository.createOrder(
      distributorId: distributorId,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryRequest: deliveryRequest,
      desiredDeliveryDate: desiredDeliveryDate,
      items: items,
    );
  }
}

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<entities.Order>>> call() async {
    return await repository.getOrders();
  }
}

class GetDistributorOrdersUseCase {
  final OrderRepository repository;

  GetDistributorOrdersUseCase(this.repository);

  Future<Either<Failure, List<entities.Order>>> call() async {
    return await repository.getDistributorOrders();
  }
}

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Either<Failure, entities.Order>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}

class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Either<Failure, entities.Order>> call(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}

class ConfirmPaymentUseCase {
  final OrderRepository repository;

  ConfirmPaymentUseCase(this.repository);

  Future<Either<Failure, entities.Order>> call({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    return await repository.confirmPayment(
      orderId: orderId,
      paymentKey: paymentKey,
      amount: amount,
    );
  }
}
