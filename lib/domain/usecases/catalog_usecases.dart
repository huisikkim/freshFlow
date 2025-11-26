import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/domain/repositories/catalog_repository.dart';

// 유통업체용
class CreateProductUseCase {
  final CatalogRepository repository;
  CreateProductUseCase(this.repository);

  Future<Product> execute({
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
    return await repository.createProduct(
      productName: productName,
      category: category,
      description: description,
      unitPrice: unitPrice,
      unit: unit,
      stockQuantity: stockQuantity,
      origin: origin,
      brand: brand,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      minOrderQuantity: minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity,
      certifications: certifications,
    );
  }
}

class GetMyProductsUseCase {
  final CatalogRepository repository;
  GetMyProductsUseCase(this.repository);

  Future<List<Product>> execute() async {
    return await repository.getMyProducts();
  }
}

class UpdateProductUseCase {
  final CatalogRepository repository;
  UpdateProductUseCase(this.repository);

  Future<Product> execute(int productId, Map<String, dynamic> updates) async {
    return await repository.updateProduct(productId, updates);
  }
}

class DeleteProductUseCase {
  final CatalogRepository repository;
  DeleteProductUseCase(this.repository);

  Future<void> execute(int productId) async {
    return await repository.deleteProduct(productId);
  }
}

class UpdateStockUseCase {
  final CatalogRepository repository;
  UpdateStockUseCase(this.repository);

  Future<Product> execute(int productId, int quantity) async {
    return await repository.updateStock(productId, quantity);
  }
}

class ToggleAvailabilityUseCase {
  final CatalogRepository repository;
  ToggleAvailabilityUseCase(this.repository);

  Future<Product> execute(int productId) async {
    return await repository.toggleAvailability(productId);
  }
}

// 매장용
class GetDistributorCatalogUseCase {
  final CatalogRepository repository;
  GetDistributorCatalogUseCase(this.repository);

  Future<List<Product>> execute(String distributorId) async {
    return await repository.getDistributorCatalog(distributorId);
  }
}

class GetProductsByCategoryUseCase {
  final CatalogRepository repository;
  GetProductsByCategoryUseCase(this.repository);

  Future<List<Product>> execute(String distributorId, String category) async {
    return await repository.getProductsByCategory(distributorId, category);
  }
}

class SearchProductsUseCase {
  final CatalogRepository repository;
  SearchProductsUseCase(this.repository);

  Future<List<Product>> execute(String distributorId, String keyword) async {
    return await repository.searchProducts(distributorId, keyword);
  }
}

class GetProductsByPriceRangeUseCase {
  final CatalogRepository repository;
  GetProductsByPriceRangeUseCase(this.repository);

  Future<List<Product>> execute(
      String distributorId, int minPrice, int maxPrice) async {
    return await repository.getProductsByPriceRange(
        distributorId, minPrice, maxPrice);
  }
}

class GetInStockProductsUseCase {
  final CatalogRepository repository;
  GetInStockProductsUseCase(this.repository);

  Future<List<Product>> execute(String distributorId) async {
    return await repository.getInStockProducts(distributorId);
  }
}

class GetProductDetailUseCase {
  final CatalogRepository repository;
  GetProductDetailUseCase(this.repository);

  Future<Product> execute(int productId) async {
    return await repository.getProductDetail(productId);
  }
}
