import 'package:flutter/foundation.dart';
import 'package:fresh_flow/data/datasources/settlement_remote_datasource.dart';
import 'package:fresh_flow/data/models/settlement_model.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';

class SettlementProvider with ChangeNotifier {
  final SettlementRemoteDataSource _dataSource;
  final AuthRepository _authRepository;

  SettlementProvider(this._dataSource, this._authRepository);

  bool _isLoading = false;
  String? _error;

  // 개별 정산 목록
  List<SettlementModel> _settlements = [];
  
  // 일일 정산 목록
  List<DailySettlementModel> _dailySettlements = [];
  
  // 정산 통계
  SettlementStatisticsModel? _statistics;
  
  // 총 미수금
  int _totalOutstanding = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SettlementModel> get settlements => _settlements;
  List<DailySettlementModel> get dailySettlements => _dailySettlements;
  SettlementStatisticsModel? get statistics => _statistics;
  int get totalOutstanding => _totalOutstanding;

  /// 가게별 정산 목록 조회
  Future<void> fetchStoreSettlements(String storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _settlements = await _dataSource.getStoreSettlements(token, storeId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _settlements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 유통업자별 정산 목록 조회
  Future<void> fetchDistributorSettlements(String distributorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _settlements = await _dataSource.getDistributorSettlements(token, distributorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _settlements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 정산 완료 처리
  Future<bool> completeSettlement(String settlementId, int paidAmount) async {
    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      await _dataSource.completeSettlement(token, settlementId, paidAmount);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 총 미수금 조회
  Future<void> fetchTotalOutstanding(String storeId) async {
    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      final result = await _dataSource.getTotalOutstanding(token, storeId);
      _totalOutstanding = result.totalOutstanding;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 가게별 일일 정산 조회
  Future<void> fetchStoreDailySettlements(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _dailySettlements = await _dataSource.getStoreDailySettlements(
        token,
        storeId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _dailySettlements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 유통업자별 일일 정산 조회
  Future<void> fetchDistributorDailySettlements(
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _dailySettlements = await _dataSource.getDistributorDailySettlements(
        token,
        distributorId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _dailySettlements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 가게별 정산 통계
  Future<void> fetchStoreStatistics(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _statistics = await _dataSource.getStoreStatistics(
        token,
        storeId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _statistics = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 유통업자별 정산 통계
  Future<void> fetchDistributorStatistics(
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      _statistics = await _dataSource.getDistributorStatistics(
        token,
        distributorId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _statistics = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
