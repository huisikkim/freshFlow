import 'package:fresh_flow/domain/entities/product.dart';

abstract class CatalogRepository {
  // 유통업체용
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
  });

  Future<Product> updateProduct(int productId, Map<String, dynamic> updates);

  Future<void> deleteProduct(int productId);

  Future<List<Product>> getMyProducts();

  Future<Product> updateStock(int productId, int quantity);

  Future<Product> toggleAvailability(int productId);

  Future<void> createOrUpdateDeliveryInfo({
    required int productId,
    required String deliveryType,
    required int deliveryFee,
    required int freeDeliveryThreshold,
    required String deliveryRegions,
    required String deliveryDays,
    required String deliveryTimeSlots,
    required int estimatedDeliveryDays,
    required String packagingType,
    required bool isFragile,
    required bool requiresRefrigeration,
    String? specialInstructions,
  });

  // 매장용
  Future<List<Product>> getDistributorCatalog(String distributorId);

  Future<List<Product>> getProductsByCategory(
      String distributorId, String category);

  Future<List<Product>> searchProducts(String distributorId, String keyword);

  Future<List<Product>> getProductsByPriceRange(
      String distributorId, int minPrice, int maxPrice);

  Future<List<Product>> getInStockProducts(String distributorId);

  // 공통
  Future<Product> getProductDetail(int productId);
  
  Future<Product> getProductDetailWithDelivery(int productId);
}
