import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_flow/data/models/product_model.dart';
import 'package:fresh_flow/core/constants/api_constants.dart';

abstract class CatalogRemoteDataSource {
  Future<ProductModel> createProduct(String token, Map<String, dynamic> data);
  Future<ProductModel> updateProduct(
      String token, int productId, Map<String, dynamic> updates);
  Future<void> deleteProduct(String token, int productId);
  Future<List<ProductModel>> getMyProducts(String token);
  Future<ProductModel> updateStock(String token, int productId, int quantity);
  Future<ProductModel> toggleAvailability(String token, int productId);
  Future<List<ProductModel>> getDistributorCatalog(
      String token, String distributorId);
  Future<List<ProductModel>> getProductsByCategory(
      String token, String distributorId, String category);
  Future<List<ProductModel>> searchProducts(
      String token, String distributorId, String keyword);
  Future<List<ProductModel>> getProductsByPriceRange(
      String token, String distributorId, int minPrice, int maxPrice);
  Future<List<ProductModel>> getInStockProducts(
      String token, String distributorId);
  Future<ProductModel> getProductDetail(String token, int productId);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final http.Client client;

  CatalogRemoteDataSourceImpl(this.client);

  @override
  Future<ProductModel> createProduct(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('상품 등록 실패 (${response.statusCode}): ${response.body}');
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
  Future<ProductModel> updateProduct(
      String token, int productId, Map<String, dynamic> updates) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('상품 수정 실패 (${response.statusCode})');
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
  Future<void> deleteProduct(String token, int productId) async {
    try {
      final response = await client.delete(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('상품 삭제 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> getMyProducts(String token) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogMyProductsEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('상품 목록 조회 실패 (${response.statusCode})');
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
  Future<ProductModel> updateStock(
      String token, int productId, int quantity) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}/$productId/stock?quantity=$quantity'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('재고 업데이트 실패 (${response.statusCode})');
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
  Future<ProductModel> toggleAvailability(String token, int productId) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}/$productId/toggle-availability'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('판매 상태 변경 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> getDistributorCatalog(
      String token, String distributorId) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/catalog/distributor/$distributorId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('카탈로그 조회 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> getProductsByCategory(
      String token, String distributorId, String category) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/catalog/distributor/$distributorId/category/$category'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('카테고리별 조회 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> searchProducts(
      String token, String distributorId, String keyword) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/catalog/distributor/$distributorId/search?keyword=$keyword'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('상품 검색 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> getProductsByPriceRange(
      String token, String distributorId, int minPrice, int maxPrice) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/catalog/distributor/$distributorId/price-range?minPrice=$minPrice&maxPrice=$maxPrice'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('가격 범위 검색 실패 (${response.statusCode})');
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
  Future<List<ProductModel>> getInStockProducts(
      String token, String distributorId) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/catalog/distributor/$distributorId/in-stock'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('재고 있는 상품 조회 실패 (${response.statusCode})');
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
  Future<ProductModel> getProductDetail(String token, int productId) async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.catalogProductsEndpoint}/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('상품 상세 조회 실패 (${response.statusCode})');
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
