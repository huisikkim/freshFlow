import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/cart_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> addToCart(String token, int productId, int quantity);
  Future<CartModel> getCart(String token, String distributorId);
  Future<CartModel> updateCartItemQuantity(
      String token, String distributorId, int itemId, int quantity);
  Future<void> removeCartItem(
      String token, String distributorId, int itemId);
  Future<void> clearCart(String token, String distributorId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;

  CartRemoteDataSourceImpl(this.client);

  /// JSON 응답을 정리하는 헬퍼 메서드
  /// 서버에서 잘못된 형식의 JSON을 반환할 경우 수정 시도
  String _cleanJsonResponse(String response) {
    // 중복된 닫는 괄호 제거 (예: ]}}] -> ]})
    String cleaned = response;
    
    // 연속된 ]}} 패턴을 찾아서 수정
    cleaned = cleaned.replaceAll(RegExp(r'\]\}\}\]'), ']}');
    cleaned = cleaned.replaceAll(RegExp(r'\]\}\]'), ']}');
    
    return cleaned;
  }

  @override
  Future<CartModel> addToCart(
      String token, int productId, int quantity) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        try {
          final jsonData = jsonDecode(responseBody);
          return CartModel.fromJson(jsonData);
        } catch (e) {
          print('JSON 파싱 오류: $e');
          print('원본 응답 (처음 500자): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
          
          // JSON 정리 시도
          try {
            final cleanedResponse = _cleanJsonResponse(responseBody);
            print('정리된 응답 시도 중...');
            final jsonData = jsonDecode(cleanedResponse);
            return CartModel.fromJson(jsonData);
          } catch (e2) {
            print('정리 후에도 파싱 실패: $e2');
            throw Exception('서버 응답 형식이 올바르지 않습니다. 서버 측 JSON 형식을 확인해주세요.');
          }
        }
      } else {
        throw Exception('장바구니 추가 실패 (${response.statusCode}): ${response.body}');
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
  Future<CartModel> getCart(String token, String distributorId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/$distributorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        try {
          final jsonData = jsonDecode(responseBody);
          return CartModel.fromJson(jsonData);
        } catch (e) {
          print('JSON 파싱 오류: $e');
          print('원본 응답 (처음 1000자): ${responseBody.substring(0, responseBody.length > 1000 ? 1000 : responseBody.length)}');
          print('원본 응답 (마지막 200자): ${responseBody.substring(responseBody.length > 200 ? responseBody.length - 200 : 0)}');
          
          // JSON 정리 시도
          try {
            final cleanedResponse = _cleanJsonResponse(responseBody);
            print('정리된 응답 시도 중...');
            final jsonData = jsonDecode(cleanedResponse);
            return CartModel.fromJson(jsonData);
          } catch (e2) {
            print('정리 후에도 파싱 실패: $e2');
            throw Exception('서버 응답 형식이 올바르지 않습니다. 서버 측 JSON 형식을 확인해주세요.');
          }
        }
      } else {
        throw Exception('장바구니 조회 실패 (${response.statusCode})');
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
  Future<CartModel> updateCartItemQuantity(
      String token, String distributorId, int itemId, int quantity) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/cart/$distributorId/items/$itemId?quantity=$quantity'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        try {
          final jsonData = jsonDecode(responseBody);
          return CartModel.fromJson(jsonData);
        } catch (e) {
          print('JSON 파싱 오류: $e');
          print('원본 응답: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
          
          // JSON 정리 시도
          try {
            final cleanedResponse = _cleanJsonResponse(responseBody);
            print('정리된 응답 시도 중...');
            final jsonData = jsonDecode(cleanedResponse);
            return CartModel.fromJson(jsonData);
          } catch (e2) {
            print('정리 후에도 파싱 실패: $e2');
            throw Exception('서버 응답 형식이 올바르지 않습니다. 서버 측 JSON 형식을 확인해주세요.');
          }
        }
      } else {
        throw Exception('수량 변경 실패 (${response.statusCode})');
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
  Future<void> removeCartItem(
      String token, String distributorId, int itemId) async {
    try {
      final response = await client.delete(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/cart/$distributorId/items/$itemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('아이템 삭제 실패 (${response.statusCode})');
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
  Future<void> clearCart(String token, String distributorId) async {
    try {
      final response = await client.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/cart/$distributorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('장바구니 비우기 실패 (${response.statusCode})');
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
