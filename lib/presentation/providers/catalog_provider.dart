import 'package:flutter/foundation.dart';
import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/domain/usecases/catalog_usecases.dart';

enum CatalogState { initial, loading, success, error }

class CatalogProvider extends ChangeNotifier {
  final CreateProductUseCase createProductUseCase;
  final GetMyProductsUseCase getMyProductsUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final UpdateStockUseCase updateStockUseCase;
  final ToggleAvailabilityUseCase toggleAvailabilityUseCase;
  final GetDistributorCatalogUseCase getDistributorCatalogUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetProductsByPriceRangeUseCase getProductsByPriceRangeUseCase;
  final GetInStockProductsUseCase getInStockProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  CatalogState _state = CatalogState.initial;
  List<Product> _products = [];
  Product? _currentProduct;
  String? _errorMessage;

  CatalogState get state => _state;
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  String? get errorMessage => _errorMessage;

  CatalogProvider({
    required this.createProductUseCase,
    required this.getMyProductsUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.updateStockUseCase,
    required this.toggleAvailabilityUseCase,
    required this.getDistributorCatalogUseCase,
    required this.getProductsByCategoryUseCase,
    required this.searchProductsUseCase,
    required this.getProductsByPriceRangeUseCase,
    required this.getInStockProductsUseCase,
    required this.getProductDetailUseCase,
  });

  Future<void> createProduct({
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
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentProduct = await createProductUseCase.execute(
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
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMyProducts() async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await getMyProductsUseCase.execute();
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDistributorCatalog(String distributorId) async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await getDistributorCatalogUseCase.execute(distributorId);
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchProducts(String distributorId, String keyword) async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await searchProductsUseCase.execute(distributorId, keyword);
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStock(int productId, int quantity) async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentProduct = await updateStockUseCase.execute(productId, quantity);
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(int productId) async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentProduct = await toggleAvailabilityUseCase.execute(productId);
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int productId) async {
    _state = CatalogState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await deleteProductUseCase.execute(productId);
      _state = CatalogState.success;
      notifyListeners();
    } catch (e) {
      _state = CatalogState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = CatalogState.initial;
    _products = [];
    _currentProduct = null;
    _errorMessage = null;
    notifyListeners();
  }
}
