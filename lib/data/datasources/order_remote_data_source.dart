import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/core/constants/api_constants.dart';
import 'package:fresh_flow/core/errors/exceptions.dart';
import 'package:fresh_flow/data/models/order_model.dart';
import 'package:fresh_flow/domain/entities/order.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String token,
    required String storeId,
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  });

  Future<List<OrderModel>> getOrders(String token, String storeId);

  Future<List<OrderModel>> getDistributorOrders(String token, String distributorId);

  Future<OrderModel> getOrderById(String token, String storeId, String orderId);

  Future<OrderModel> cancelOrder(String token, String storeId, String orderId);

  Future<OrderModel> confirmPayment({
    required String token,
    required String orderId,
    required String paymentKey,
    required int amount,
  });

  Future<OrderModel> confirmOrder({
    required String token,
    required String orderId,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client client;

  OrderRemoteDataSourceImpl(this.client);

  @override
  Future<OrderModel> createOrder({
    required String token,
    required String storeId,
    required String distributorId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryRequest,
    DateTime? desiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    // 날짜를 ISO 형식으로 변환 (밀리초 제거)
    String? formattedDate;
    if (desiredDeliveryDate != null) {
      formattedDate = desiredDeliveryDate.toUtc().toIso8601String();
      // 밀리초 제거: 2025-11-27T21:13:31.527667 -> 2025-11-27T21:13:31Z
      if (formattedDate.contains('.')) {
        formattedDate = formattedDate.split('.')[0] + 'Z';
      }
    }

    // 시도 1: items 포함 (현재 방식)
    final bodyWithItems = {
      'distributorId': distributorId,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'items': items,
      if (deliveryRequest != null && deliveryRequest.isNotEmpty) 
        'deliveryRequest': deliveryRequest,
      if (formattedDate != null) 
        'desiredDeliveryDate': formattedDate,
    };

    // 시도 2: items 없이 (서버가 장바구니에서 자동 가져오기)
    final bodyWithoutItems = {
      'distributorId': distributorId,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      if (deliveryRequest != null && deliveryRequest.isNotEmpty) 
        'deliveryRequest': deliveryRequest,
      if (formattedDate != null) 
        'desiredDeliveryDate': formattedDate,
    };

    // 먼저 items 없이 시도
    final body = bodyWithoutItems;

    print('🚀 주문 생성 요청 (items 제외 - 서버가 장바구니에서 가져옴)');
    print('URL: ${ApiConstants.baseUrl}/api/catalog-orders/create');
    print('Token: Bearer ${token.substring(0, 20)}...');
    print('StoreId: $storeId (토큰에서 추출 예상)');
    print('DistributorId: $distributorId');
    print('Body: ${json.encode(body)}');
    print('참고 - 전송할 아이템: ${items.map((i) => 'productId=${i['productId']}, quantity=${i['quantity']}').join(', ')}');

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/create'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
        // X-Store-Id 헤더 제거 - body에 포함
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');
    print('📥 응답 본문 길이: ${response.body.length}');
    print('📥 응답 본문: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw ServerException(message: '서버가 빈 응답을 반환했습니다');
      }
      final jsonResponse = json.decode(response.body);
      return OrderModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      print('❌ 인증 실패 - 토큰이 유효하지 않습니다');
      throw UnauthorizedException();
    } else {
      // 서버에서 반환한 에러 메시지 파싱 시도
      String errorMessage = 'Failed to create order';
      
      if (response.body.isEmpty) {
        errorMessage = '주문 생성 실패 (${response.statusCode}): 서버가 빈 응답을 반환했습니다.\n\n가능한 원인:\n- 장바구니가 비어있음\n- 이미 주문이 생성됨\n- 유효하지 않은 distributorId';
        print('❌ 빈 응답 본문');
      } else {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
          print('❌ 서버 에러 메시지: $errorMessage');
        } catch (e) {
          errorMessage = '${errorMessage} (${response.statusCode}): ${response.body}';
          print('❌ 에러 응답 파싱 실패: $e');
        }
      }
      
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<List<OrderModel>> getOrders(String token, String storeId) async {
    // 서버 API: GET /api/catalog-orders/my
    // 토큰에서 storeId를 추출하므로 별도 전달 불필요
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/my');
    
    print('📋 주문 목록 조회 요청');
    print('URL: $uri');
    print('Token: Bearer ${token.substring(0, 20)}...');
    print('StoreId (참고용): $storeId');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // X-Store-Id 헤더는 토큰에서 추출하므로 불필요
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');
    print('📥 응답 본문 길이: ${response.body.length}');
    if (response.body.length < 500) {
      print('📥 응답 본문: ${response.body}');
    } else {
      print('📥 응답 본문: ${response.body.substring(0, 500)}... (생략)');
    }

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        print('ℹ️ 주문 내역이 없습니다');
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      print('✅ 주문 ${jsonList.length}개 조회 성공');
      return jsonList.map((json) => OrderModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      print('❌ 인증 실패');
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to fetch orders';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage (${response.statusCode}): ${response.body}';
        }
      }
      print('❌ 주문 조회 실패: $errorMessage');
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<List<OrderModel>> getDistributorOrders(String token, String distributorId) async {
    // 유통업체가 받은 주문 목록 조회
    // 서버 API: GET /api/catalog-orders/distributor
    // 토큰에서 distributorId를 추출하므로 별도 전달 불필요
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/distributor');
    
    print('📋 유통업체 주문 목록 조회 요청');
    print('URL: $uri');
    print('Token: Bearer ${token.substring(0, 20)}...');
    print('DistributorId (참고용): $distributorId');
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');
    print('📥 응답 본문 길이: ${response.body.length}');
    if (response.body.length < 500) {
      print('📥 응답 본문: ${response.body}');
    } else {
      print('📥 응답 본문: ${response.body.substring(0, 500)}... (생략)');
    }

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '[]') {
        print('ℹ️ 받은 주문이 없습니다');
        return [];
      }
      final List<dynamic> jsonList = json.decode(response.body);
      print('✅ 주문 ${jsonList.length}개 조회 성공');
      return jsonList.map((json) => OrderModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      print('❌ 인증 실패');
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to fetch distributor orders';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage (${response.statusCode}): ${response.body}';
        }
      }
      print('❌ 유통업체 주문 조회 실패: $errorMessage');
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<OrderModel> getOrderById(String token, String storeId, String orderId) async {
    // storeId를 쿼리 파라미터로 전달
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/$orderId')
        .replace(queryParameters: {'storeId': storeId});
    
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Order not found');
    } else {
      throw ServerException(message: 'Failed to fetch order');
    }
  }

  @override
  Future<OrderModel> cancelOrder(String token, String storeId, String orderId) async {
    // storeId를 쿼리 파라미터로 전달
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/$orderId/cancel')
        .replace(queryParameters: {'storeId': storeId});
    
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Order not found');
    } else if (response.statusCode == 400) {
      final errorMessage = json.decode(response.body)['message'] ?? 'Cannot cancel order';
      throw ServerException(message: errorMessage);
    } else {
      throw ServerException(message: 'Failed to cancel order');
    }
  }

  @override
  Future<OrderModel> confirmPayment({
    required String token,
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    // 인증 불필요 (paymentKey가 인증 역할)
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentConfirmEndpoint}');
    
    final body = {
      'paymentKey': paymentKey,
      'orderId': orderId,
      'amount': amount,
    };

    print('💳 결제 승인 요청');
    print('URL: $uri');
    print('Body: ${json.encode(body)}');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );

    print('📥 응답 상태 코드: ${response.statusCode}');
    print('📥 응답 본문: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw ServerException(message: '서버가 빈 응답을 반환했습니다');
      }
      
      final paymentResponse = json.decode(response.body);
      print('✅ 결제 승인 성공: ${paymentResponse['status']}');
      print('✅ 결제 방법: ${paymentResponse['method']}');
      print('✅ 승인 시간: ${paymentResponse['approvedAt']}');
      
      // 결제 승인 성공 - 간단한 주문 정보 반환 (UI에서 성공 처리용)
      return OrderModel(
        id: orderId,
        storeId: '',
        distributorId: '',
        distributorName: '',
        items: [],
        totalAmount: amount,
        deliveryAddress: '',
        deliveryPhone: '',
        deliveryRequest: null,
        desiredDeliveryDate: null,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      String errorMessage = 'Failed to confirm payment';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage (${response.statusCode}): ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<OrderModel> confirmOrder({
    required String token,
    required String orderId,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orderConfirmEndpoint(orderId)}');

    print('✅ 주문 확정 요청');
    print('URL: $uri');

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 응답 상태 코드: ${response.statusCode}');
    print('📥 응답 본문: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw ServerException(message: '서버가 빈 응답을 반환했습니다');
      }
      return OrderModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: 'Order not found');
    } else {
      String errorMessage = 'Failed to confirm order';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = '$errorMessage (${response.statusCode}): ${response.body}';
        }
      }
      throw ServerException(message: errorMessage);
    }
  }
}
