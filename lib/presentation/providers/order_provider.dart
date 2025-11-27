import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/order.dart';
import 'package:fresh_flow/domain/usecases/order_usecases.dart';

enum OrderState { initial, loading, loaded, error }

class OrderProvider with ChangeNotifier {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetDistributorOrdersUseCase getDistributorOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  OrderState _state = OrderState.initial;
  String? _errorMessage;
  List<Order> _orders = [];
  Order? _currentOrder;

  OrderState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;

  OrderProvider({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.getDistributorOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.cancelOrderUseCase,
    required this.confirmPaymentUseCase,
  });

  Future<bool> createOrder({
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await createOrderUseCase(
      distributorId: distributorId,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryRequest: deliveryRequest,
      desiredDeliveryDate: desiredDeliveryDate,
      items: items,
    );

    return result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (order) {
        _state = OrderState.loaded;
        _currentOrder = order;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> getOrders() async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getOrdersUseCase();

    result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (orders) {
        _state = OrderState.loaded;
        _orders = orders;
        notifyListeners();
      },
    );
  }

  Future<void> getDistributorOrders() async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getDistributorOrdersUseCase();

    result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (orders) {
        _state = OrderState.loaded;
        _orders = orders;
        notifyListeners();
      },
    );
  }

  Future<void> getOrderById(String orderId) async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getOrderByIdUseCase(orderId);

    result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (order) {
        _state = OrderState.loaded;
        _currentOrder = order;
        notifyListeners();
      },
    );
  }

  Future<bool> cancelOrder(String orderId) async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await cancelOrderUseCase(orderId);

    return result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (order) {
        _state = OrderState.loaded;
        _currentOrder = order;
        // 목록에서도 업데이트
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = order;
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> confirmPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    _state = OrderState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await confirmPaymentUseCase(
      orderId: orderId,
      paymentKey: paymentKey,
      amount: amount,
    );

    return result.fold(
      (failure) {
        _state = OrderState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (order) {
        _state = OrderState.loaded;
        _currentOrder = order;
        notifyListeners();
        return true;
      },
    );
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
