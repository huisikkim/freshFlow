import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/distributor.dart';
import 'package:fresh_flow/domain/usecases/register_distributor_usecase.dart';

enum DistributorState { initial, loading, success, error }

class DistributorProvider extends ChangeNotifier {
  final RegisterDistributorUseCase registerDistributorUseCase;

  DistributorState _state = DistributorState.initial;
  Distributor? _distributor;
  String? _errorMessage;

  DistributorState get state => _state;
  Distributor? get distributor => _distributor;
  String? get errorMessage => _errorMessage;

  DistributorProvider({required this.registerDistributorUseCase});

  Future<void> registerDistributor({
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
    _state = DistributorState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _distributor = await registerDistributorUseCase.execute(
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
      _state = DistributorState.success;
      notifyListeners();
    } catch (e) {
      _state = DistributorState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = DistributorState.initial;
    _distributor = null;
    _errorMessage = null;
    notifyListeners();
  }
}
