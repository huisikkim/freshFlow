import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/distributor_recommendation_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class MatchingRemoteDataSource {
  Future<List<DistributorRecommendationModel>> getRecommendations({
    required String token,
    int limit = 10,
  });
}

class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  final http.Client client;

  MatchingRemoteDataSourceImpl(this.client);

  @override
  Future<List<DistributorRecommendationModel>> getRecommendations({
    required String token,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.matchingRecommendEndpoint}?limit=$limit');
      
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => DistributorRecommendationModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        // 매장 정보가 없거나 추천할 유통업체가 없는 경우
        return [];
      } else {
        throw Exception('추천 조회 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception('서버에 연결할 수 없습니다. 네트워크 연결을 확인해주세요.');
      }
      rethrow;
    }
  }
}
