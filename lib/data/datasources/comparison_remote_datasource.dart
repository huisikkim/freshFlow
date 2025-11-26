import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/distributor_comparison_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class ComparisonRemoteDataSource {
  Future<List<DistributorComparisonModel>> compareTopDistributors({
    required String token,
    int topN = 5,
  });

  Future<List<DistributorComparisonModel>> compareDistributors({
    required String token,
    required List<String> distributorIds,
  });

  Future<Map<String, DistributorComparisonModel>> findBestByCategory({
    required String token,
    required List<String> distributorIds,
  });
}

class ComparisonRemoteDataSourceImpl implements ComparisonRemoteDataSource {
  final http.Client client;

  ComparisonRemoteDataSourceImpl(this.client);

  @override
  Future<List<DistributorComparisonModel>> compareTopDistributors({
    required String token,
    int topN = 5,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.compareTopEndpoint}?topN=$topN'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => DistributorComparisonModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('비교 조회 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<List<DistributorComparisonModel>> compareDistributors({
    required String token,
    required List<String> distributorIds,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.compareEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(distributorIds),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => DistributorComparisonModel.fromJson(json))
            .toList();
      } else {
        throw Exception('비교 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, DistributorComparisonModel>> findBestByCategory({
    required String token,
    required List<String> distributorIds,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.compareBestByCategoryEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(distributorIds),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonMap.map(
          (key, value) => MapEntry(
            key,
            DistributorComparisonModel.fromJson(value),
          ),
        );
      } else {
        throw Exception(
            '카테고리별 최고 조회 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다.');
      }
      rethrow;
    }
  }
}
