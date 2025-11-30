import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/store.dart';
import 'package:fresh_flow/domain/usecases/register_store_usecase.dart';
import 'package:fresh_flow/domain/usecases/get_store_info_usecase.dart';

enum StoreState { initial, loading, success, error }

class StoreProvider extends ChangeNotifier {
  final RegisterStoreUseCase registerStoreUseCase;
  final GetStoreInfoUseCase getStoreInfoUseCase;

  StoreState _state = StoreState.initial;
  Store? _store;
  String? _errorMessage;

  StoreState get state => _state;
  Store? get store => _store;
  String? get errorMessage => _errorMessage;

  StoreProvider({
    required this.registerStoreUseCase,
    required this.getStoreInfoUseCase,
  });

  Future<void> registerStore({
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
    _state = StoreState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _store = await registerStoreUseCase.execute(
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
      _state = StoreState.success;
      notifyListeners();
    } catch (e) {
      _state = StoreState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStoreInfo() async {
    _state = StoreState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _store = await getStoreInfoUseCase.execute();
      // 조회는 성공 상태로 변경하지 않음 (initial로 유지)
      _state = StoreState.initial;
      notifyListeners();
    } catch (e) {
      _state = StoreState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = StoreState.initial;
    _store = null;
    _errorMessage = null;
    notifyListeners();
  }
}
