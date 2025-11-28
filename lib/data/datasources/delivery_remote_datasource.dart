import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/core/errors/exceptions.dart';
import 'package:fresh_flow/data/models/delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<List<DeliveryModel>> getStoreDeliveries(String token);
  Future<DeliveryModel> getDeliveryByOrder(String token, String orderId);
  Future<DeliveryModel> createDelivery(String token, String orderId);
  Future<DeliveryModel> shipDeliveryCourier({
    required String token,
    required String orderId,
    required String trackingNumber,
    required String courierCompany,
    required DateTime estimatedDeliveryDate,
  });

  Future<DeliveryModel> shipDeliveryDirect({
    required String token,
    required String orderId,
    required String driverName,
    required String driverPhone,
    required String vehicleNumber,
    required DateTime estimatedDeliveryDate,
  });
  Future<DeliveryModel> completeDelivery(String token, String orderId);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final http.Client client;

  DeliveryRemoteDataSourceImpl(this.client);

  @override
  Future<List<DeliveryModel>> getStoreDeliveries(String token) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deliveriesStoreEndpoint}');
    
    print('📦 가게 배송 목록 조회 요청');
    print('URL: $uri');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => DeliveryModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException(message: 'Failed to fetch deliveries');
    }
  }

  @override
  Future<DeliveryModel> getDeliveryByOrder(String token, String orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deliveryByOrderEndpoint(orderId)}');
    
    print('📦 주문별 배송 조회 요청');
    print('URL: $uri');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      return DeliveryModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Delivery not found');
    } else {
      throw ServerException(message: 'Failed to fetch delivery');
    }
  }

  @override
  Future<DeliveryModel> createDelivery(String token, String orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createDeliveryEndpoint(orderId)}');
    
    print('📦 배송 정보 생성 요청');
    print('URL: $uri');
    
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DeliveryModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to create delivery';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<DeliveryModel> shipDeliveryCourier({
    required String token,
    required String orderId,
    required String trackingNumber,
    required String courierCompany,
    required DateTime estimatedDeliveryDate,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.shipDeliveryEndpoint(orderId)}');

    final body = {
      'deliveryType': 'COURIER',
      'trackingNumber': trackingNumber,
      'courierCompany': courierCompany,
      'estimatedDeliveryDate': estimatedDeliveryDate.toIso8601String(),
    };

    print('🚚 택배 배송 시작 요청');
    print('URL: $uri');
    print('Body: ${json.encode(body)}');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DeliveryModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to ship delivery';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<DeliveryModel> shipDeliveryDirect({
    required String token,
    required String orderId,
    required String driverName,
    required String driverPhone,
    required String vehicleNumber,
    required DateTime estimatedDeliveryDate,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.shipDeliveryEndpoint(orderId)}');

    final body = {
      'deliveryType': 'DIRECT',
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate.toIso8601String(),
    };

    print('🚚 직접 배송 시작 요청');
    print('URL: $uri');
    print('Body: ${json.encode(body)}');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DeliveryModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to ship delivery';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage =
              errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<DeliveryModel> completeDelivery(String token, String orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeDeliveryEndpoint(orderId)}');
    
    print('✅ 배송 완료 요청');
    print('URL: $uri');
    
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DeliveryModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to complete delivery';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage: ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }
}
