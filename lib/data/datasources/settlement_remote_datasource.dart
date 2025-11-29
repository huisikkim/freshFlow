import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/core/errors/exceptions.dart';
import 'package:fresh_flow/data/models/settlement_model.dart';

abstract class SettlementRemoteDataSource {
  /// 가게별 정산 목록 조회
  Future<List<SettlementModel>> getStoreSettlements(String token, String storeId);

  /// 유통업자별 정산 목록 조회
  Future<List<SettlementModel>> getDistributorSettlements(String token, String distributorId);

  /// 정산 상세 조회
  Future<SettlementModel> getSettlementById(String token, String settlementId);

  /// 정산 완료 처리
  Future<void> completeSettlement(String token, String settlementId, int paidAmount);

  /// 총 미수금 조회
  Future<TotalOutstandingModel> getTotalOutstanding(String token, String storeId);

  /// 가게별 일일 정산 조회
  Future<List<DailySettlementModel>> getStoreDailySettlements(
    String token,
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 유통업자별 일일 정산 조회
  Future<List<DailySettlementModel>> getDistributorDailySettlements(
    String token,
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 가게별 정산 통계
  Future<SettlementStatisticsModel> getStoreStatistics(
    String token,
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 유통업자별 정산 통계
  Future<SettlementStatisticsModel> getDistributorStatistics(
    String token,
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  final http.Client client;

  SettlementRemoteDataSourceImpl(this.client);

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<SettlementModel>> getStoreSettlements(String token, String storeId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/settlements/store/$storeId');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SettlementModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch store settlements');
    }
  }

  @override
  Future<List<SettlementModel>> getDistributorSettlements(String token, String distributorId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/settlements/distributor/$distributorId');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SettlementModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch distributor settlements');
    }
  }

  @override
  Future<SettlementModel> getSettlementById(String token, String settlementId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/settlements/$settlementId');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SettlementModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Settlement not found');
    } else {
      throw ServerException(message: 'Failed to fetch settlement');
    }
  }

  @override
  Future<void> completeSettlement(String token, String settlementId, int paidAmount) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/settlements/$settlementId/complete');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'paidAmount': paidAmount}),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Settlement not found');
    } else {
      throw ServerException(message: 'Failed to complete settlement');
    }
  }

  @override
  Future<TotalOutstandingModel> getTotalOutstanding(String token, String storeId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/settlements/store/$storeId/outstanding');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return TotalOutstandingModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch total outstanding');
    }
  }

  @override
  Future<List<DailySettlementModel>> getStoreDailySettlements(
    String token,
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = _formatDate(startDate);
    if (endDate != null) queryParams['endDate'] = _formatDate(endDate);

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/daily-settlements/store/$storeId')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => DailySettlementModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch daily settlements');
    }
  }

  @override
  Future<List<DailySettlementModel>> getDistributorDailySettlements(
    String token,
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = _formatDate(startDate);
    if (endDate != null) queryParams['endDate'] = _formatDate(endDate);

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/daily-settlements/distributor/$distributorId')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => DailySettlementModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch daily settlements');
    }
  }

  @override
  Future<SettlementStatisticsModel> getStoreStatistics(
    String token,
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = _formatDate(startDate);
    if (endDate != null) queryParams['endDate'] = _formatDate(endDate);

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/daily-settlements/store/$storeId/statistics')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SettlementStatisticsModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch statistics');
    }
  }

  @override
  Future<SettlementStatisticsModel> getDistributorStatistics(
    String token,
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = _formatDate(startDate);
    if (endDate != null) queryParams['endDate'] = _formatDate(endDate);

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/daily-settlements/distributor/$distributorId/statistics')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SettlementStatisticsModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch statistics');
    }
  }
}
