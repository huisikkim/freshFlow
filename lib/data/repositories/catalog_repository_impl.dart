import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/domain/repositories/catalog_repository.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/data/datasources/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  CatalogRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  Future<String> _getToken() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }
    return user.accessToken;
  }

  @override
  Future<Product> createProduct({
    required String productName,
    required String category,
    required String description,
    required int unitPrice,
    required String unit,
    required int stockQuantity,
    required String origin,
    required String brand,
    String? imageUrl,
    required bool isAvailable,
    required int minOrderQuantity,
    required int maxOrderQuantity,
    String? certifications,
  }) async {
    final token = await _getToken();
    final data = {
      'productName': productName,
      'category': category,
      'description': description,
      'unitPrice': unitPrice,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'origin': origin,
      'brand': brand,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      if (certifications != null) 'certifications': certifications,
    };
    return await remoteDataSource.createProduct(token, data);
  }

  @override
  Future<Product> updateProduct(
      int productId, Map<String, dynamic> updates) async {
    final token = await _getToken();
    return await remoteDataSource.updateProduct(token, productId, updates);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    final token = await _getToken();
    return await remoteDataSource.deleteProduct(token, productId);
  }

  @override
  Future<List<Product>> getMyProducts() async {
    final token = await _getToken();
    return await remoteDataSource.getMyProducts(token);
  }

  @override
  Future<Product> updateStock(int productId, int quantity) async {
    final token = await _getToken();
    return await remoteDataSource.updateStock(token, productId, quantity);
  }

  @override
  Future<Product> toggleAvailability(int productId) async {
    final token = await _getToken();
    return await remoteDataSource.toggleAvailability(token, productId);
  }

  @override
  Future<List<Product>> getDistributorCatalog(String distributorId) async {
    final token = await _getToken();
    return await remoteDataSource.getDistributorCatalog(token, distributorId);
  }

  @override
  Future<List<Product>> getProductsByCategory(
      String distributorId, String category) async {
    final token = await _getToken();
    return await remoteDataSource.getProductsByCategory(
        token, distributorId, category);
  }

  @override
  Future<List<Product>> searchProducts(
      String distributorId, String keyword) async {
    final token = await _getToken();
    return await remoteDataSource.searchProducts(
        token, distributorId, keyword);
  }

  @override
  Future<List<Product>> getProductsByPriceRange(
      String distributorId, int minPrice, int maxPrice) async {
    final token = await _getToken();
    return await remoteDataSource.getProductsByPriceRange(
        token, distributorId, minPrice, maxPrice);
  }

  @override
  Future<List<Product>> getInStockProducts(String distributorId) async {
    final token = await _getToken();
    return await remoteDataSource.getInStockProducts(token, distributorId);
  }

  @override
  Future<Product> getProductDetail(int productId) async {
    final token = await _getToken();
    return await remoteDataSource.getProductDetail(token, productId);
  }
}
