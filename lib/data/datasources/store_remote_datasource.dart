import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/store_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class StoreRemoteDataSource {
  Future<StoreModel> registerStore({
    required String token,
    required String storeName,
    required String businessType,
    required String region,
    required String mainProducts,
    required String description,
    required int employeeCount,
    required String operatingHours,
    required String phoneNumber,
    required String address,
  });
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final http.Client client;

  StoreRemoteDataSourceImpl(this.client);

  @override
  Future<StoreModel> registerStore({
    required String token,
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
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.storeInfoEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'storeName': storeName,
        'businessType': businessType,
        'region': region,
        'mainProducts': mainProducts,
        'description': description,
        'employeeCount': employeeCount,
        'operatingHours': operatingHours,
        'phoneNumber': phoneNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return StoreModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('매장 등록에 실패했습니다: ${response.body}');
    }
  }
}
