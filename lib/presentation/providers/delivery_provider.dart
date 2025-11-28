import 'package:flutter/material.dart';
import 'package:fresh_flow/data/datasources/delivery_remote_datasource.dart';
import 'package:fresh_flow/domain/entities/delivery.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

enum DeliveryState { initial, loading, loaded, error }

class DeliveryProvider with ChangeNotifier {
  final DeliveryRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  DeliveryProvider({
    required this.remoteDataSource,
    required this.authRepository,
  });

  DeliveryState _state = DeliveryState.initial;
  List<Delivery> _deliveries = [];
  Delivery? _currentDelivery;
  String? _errorMessage;

  DeliveryState get state => _state;
  List<Delivery> get deliveries => _deliveries;
  Delivery? get currentDelivery => _currentDelivery;
  String? get errorMessage => _errorMessage;

  Future<void> getStoreDeliveries() async {
    _state = DeliveryState.loading;
    notifyListeners();

    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _deliveries = await remoteDataSource.getStoreDeliveries(token);
      _state = DeliveryState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = DeliveryState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> getDeliveryByOrder(String orderId) async {
    _state = DeliveryState.loading;
    notifyListeners();

    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _currentDelivery = await remoteDataSource.getDeliveryByOrder(token, orderId);
      _state = DeliveryState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = DeliveryState.error;
      _errorMessage = e.toString();
      _currentDelivery = null;
    }
    notifyListeners();
  }

  Future<bool> createDelivery(String orderId) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _currentDelivery = await remoteDataSource.createDelivery(token, orderId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> shipDeliveryCourier({
    required String orderId,
    required String trackingNumber,
    required String courierCompany,
    required DateTime estimatedDeliveryDate,
  }) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _currentDelivery = await remoteDataSource.shipDeliveryCourier(
        token: token,
        orderId: orderId,
        trackingNumber: trackingNumber,
        courierCompany: courierCompany,
        estimatedDeliveryDate: estimatedDeliveryDate,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> shipDeliveryDirect({
    required String orderId,
    required String driverName,
    required String driverPhone,
    required String vehicleNumber,
    required DateTime estimatedDeliveryDate,
  }) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _currentDelivery = await remoteDataSource.shipDeliveryDirect(
        token: token,
        orderId: orderId,
        driverName: driverName,
        driverPhone: driverPhone,
        vehicleNumber: vehicleNumber,
        estimatedDeliveryDate: estimatedDeliveryDate,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeDelivery(String orderId) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      _currentDelivery = await remoteDataSource.completeDelivery(token, orderId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
