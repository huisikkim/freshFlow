import 'package:dartz/dartz.dart';
import 'package:fresh_flow/core/errors/failures.dart';
import 'package:fresh_flow/domain/entities/order.dart' as entities;

abstract class OrderRepository {
  Future<Either<Failure, entities.Order>> createOrder({
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  });

  Future<Either<Failure, List<entities.Order>>> getOrders();

  Future<Either<Failure, List<entities.Order>>> getDistributorOrders();

  Future<Either<Failure, entities.Order>> getOrderById(String orderId);

  Future<Either<Failure, entities.Order>> cancelOrder(String orderId);
}
