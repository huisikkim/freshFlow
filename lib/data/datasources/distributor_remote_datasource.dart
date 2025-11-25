import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/distributor_model.dart';

abstract class DistributorRemoteDataSource {
  Future<DistributorModel> registerDistributor({
    required String token,
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
  });
}

class DistributorRemoteDataSourceImpl implements DistributorRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'http://localhost:8080';

  DistributorRemoteDataSourceImpl(this.client);

  @override
  Future<DistributorModel> registerDistributor({
    required String token,
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
    final response = await client.post(
      Uri.parse('$baseUrl/api/distributor/info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'distributorName': distributorName,
        'supplyProducts': supplyProducts,
        'serviceRegions': serviceRegions,
        'deliveryAvailable': deliveryAvailable,
        'deliveryInfo': deliveryInfo,
        'description': description,
        'certifications': certifications,
        'minOrderAmount': minOrderAmount,
        'operatingHours': operatingHours,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return DistributorModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('유통업자 정보 등록에 실패했습니다: ${response.body}');
    }
  }
}
