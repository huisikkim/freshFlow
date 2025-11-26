import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_flow/data/datasources/auth_local_datasource.dart';
import 'package:fresh_flow/data/datasources/auth_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/store_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/distributor_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/matching_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/quote_request_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/comparison_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/catalog_remote_datasource.dart';
import 'package:fresh_flow/data/repositories/auth_repository_impl.dart';
import 'package:fresh_flow/data/repositories/store_repository_impl.dart';
import 'package:fresh_flow/data/repositories/distributor_repository_impl.dart';
import 'package:fresh_flow/data/repositories/matching_repository_impl.dart';
import 'package:fresh_flow/data/repositories/quote_request_repository_impl.dart';
import 'package:fresh_flow/data/repositories/comparison_repository_impl.dart';
import 'package:fresh_flow/data/repositories/catalog_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/auth_repository.dart';
import 'package:fresh_flow/domain/repositories/store_repository.dart';
import 'package:fresh_flow/domain/repositories/distributor_repository.dart';
import 'package:fresh_flow/domain/repositories/matching_repository.dart';
import 'package:fresh_flow/domain/repositories/quote_request_repository.dart';
import 'package:fresh_flow/domain/repositories/comparison_repository.dart';
import 'package:fresh_flow/domain/repositories/catalog_repository.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/usecases/signup_usecase.dart';
import 'package:fresh_flow/domain/usecases/register_store_usecase.dart';
import 'package:fresh_flow/domain/usecases/register_distributor_usecase.dart';
import 'package:fresh_flow/domain/usecases/get_recommendations_usecase.dart';
import 'package:fresh_flow/domain/usecases/quote_request_usecases.dart';
import 'package:fresh_flow/domain/usecases/comparison_usecases.dart';
import 'package:fresh_flow/domain/usecases/catalog_usecases.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/store_provider.dart';
import 'package:fresh_flow/presentation/providers/distributor_provider.dart';
import 'package:fresh_flow/presentation/providers/matching_provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/presentation/providers/comparison_provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';

class InjectionContainer {
  static late SharedPreferences _sharedPreferences;
  static late http.Client _httpClient;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthLocalDataSource _authLocalDataSource;
  static late StoreRemoteDataSource _storeRemoteDataSource;
  static late DistributorRemoteDataSource _distributorRemoteDataSource;
  static late MatchingRemoteDataSource _matchingRemoteDataSource;
  static late QuoteRequestRemoteDataSource _quoteRequestRemoteDataSource;
  static late AuthRepository _authRepository;
  static late StoreRepository _storeRepository;
  static late DistributorRepository _distributorRepository;
  static late MatchingRepository _matchingRepository;
  static late QuoteRequestRepository _quoteRequestRepository;
  static late LoginUseCase _loginUseCase;
  static late SignUpUseCase _signUpUseCase;
  static late RegisterStoreUseCase _registerStoreUseCase;
  static late RegisterDistributorUseCase _registerDistributorUseCase;
  static late GetRecommendationsUseCase _getRecommendationsUseCase;
  static late CreateQuoteRequestUseCase _createQuoteRequestUseCase;
  static late GetStoreQuoteRequestsUseCase _getStoreQuoteRequestsUseCase;
  static late GetDistributorQuoteRequestsUseCase
      _getDistributorQuoteRequestsUseCase;
  static late RespondToQuoteRequestUseCase _respondToQuoteRequestUseCase;
  static late CompleteQuoteRequestUseCase _completeQuoteRequestUseCase;
  static late CancelQuoteRequestUseCase _cancelQuoteRequestUseCase;
  static late ComparisonRemoteDataSource _comparisonRemoteDataSource;
  static late ComparisonRepository _comparisonRepository;
  static late CompareTopDistributorsUseCase _compareTopDistributorsUseCase;
  static late CompareDistributorsUseCase _compareDistributorsUseCase;
  static late FindBestByCategoryUseCase _findBestByCategoryUseCase;
  static late CatalogRemoteDataSource _catalogRemoteDataSource;
  static late CatalogRepository _catalogRepository;
  static late CreateProductUseCase _createProductUseCase;
  static late GetMyProductsUseCase _getMyProductsUseCase;
  static late UpdateProductUseCase _updateProductUseCase;
  static late DeleteProductUseCase _deleteProductUseCase;
  static late UpdateStockUseCase _updateStockUseCase;
  static late ToggleAvailabilityUseCase _toggleAvailabilityUseCase;
  static late GetDistributorCatalogUseCase _getDistributorCatalogUseCase;
  static late GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  static late SearchProductsUseCase _searchProductsUseCase;
  static late GetProductsByPriceRangeUseCase _getProductsByPriceRangeUseCase;
  static late GetInStockProductsUseCase _getInStockProductsUseCase;
  static late GetProductDetailUseCase _getProductDetailUseCase;

  static Future<void> init() async {
    // External
    _sharedPreferences = await SharedPreferences.getInstance();
    _httpClient = http.Client();

    // Data sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_httpClient);
    _authLocalDataSource = AuthLocalDataSourceImpl(_sharedPreferences);
    _storeRemoteDataSource = StoreRemoteDataSourceImpl(_httpClient);
    _distributorRemoteDataSource = DistributorRemoteDataSourceImpl(_httpClient);
    _matchingRemoteDataSource = MatchingRemoteDataSourceImpl(_httpClient);
    _quoteRequestRemoteDataSource =
        QuoteRequestRemoteDataSourceImpl(_httpClient);
    _comparisonRemoteDataSource = ComparisonRemoteDataSourceImpl(_httpClient);
    _catalogRemoteDataSource = CatalogRemoteDataSourceImpl(_httpClient);

    // Repository
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _storeRepository = StoreRepositoryImpl(
      remoteDataSource: _storeRemoteDataSource,
      authRepository: _authRepository,
    );
    _distributorRepository = DistributorRepositoryImpl(
      remoteDataSource: _distributorRemoteDataSource,
      authRepository: _authRepository,
    );
    _matchingRepository = MatchingRepositoryImpl(
      remoteDataSource: _matchingRemoteDataSource,
      authRepository: _authRepository,
    );
    _quoteRequestRepository = QuoteRequestRepositoryImpl(
      remoteDataSource: _quoteRequestRemoteDataSource,
      authRepository: _authRepository,
    );
    _comparisonRepository = ComparisonRepositoryImpl(
      remoteDataSource: _comparisonRemoteDataSource,
      authRepository: _authRepository,
    );
    _catalogRepository = CatalogRepositoryImpl(
      remoteDataSource: _catalogRemoteDataSource,
      authRepository: _authRepository,
    );

    // Use cases
    _loginUseCase = LoginUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _registerStoreUseCase = RegisterStoreUseCase(_storeRepository);
    _registerDistributorUseCase =
        RegisterDistributorUseCase(_distributorRepository);
    _getRecommendationsUseCase = GetRecommendationsUseCase(_matchingRepository);
    _createQuoteRequestUseCase =
        CreateQuoteRequestUseCase(_quoteRequestRepository);
    _getStoreQuoteRequestsUseCase =
        GetStoreQuoteRequestsUseCase(_quoteRequestRepository);
    _getDistributorQuoteRequestsUseCase =
        GetDistributorQuoteRequestsUseCase(_quoteRequestRepository);
    _respondToQuoteRequestUseCase =
        RespondToQuoteRequestUseCase(_quoteRequestRepository);
    _completeQuoteRequestUseCase =
        CompleteQuoteRequestUseCase(_quoteRequestRepository);
    _cancelQuoteRequestUseCase =
        CancelQuoteRequestUseCase(_quoteRequestRepository);
    _compareTopDistributorsUseCase =
        CompareTopDistributorsUseCase(_comparisonRepository);
    _compareDistributorsUseCase =
        CompareDistributorsUseCase(_comparisonRepository);
    _findBestByCategoryUseCase =
        FindBestByCategoryUseCase(_comparisonRepository);
    _createProductUseCase = CreateProductUseCase(_catalogRepository);
    _getMyProductsUseCase = GetMyProductsUseCase(_catalogRepository);
    _updateProductUseCase = UpdateProductUseCase(_catalogRepository);
    _deleteProductUseCase = DeleteProductUseCase(_catalogRepository);
    _updateStockUseCase = UpdateStockUseCase(_catalogRepository);
    _toggleAvailabilityUseCase = ToggleAvailabilityUseCase(_catalogRepository);
    _getDistributorCatalogUseCase =
        GetDistributorCatalogUseCase(_catalogRepository);
    _getProductsByCategoryUseCase =
        GetProductsByCategoryUseCase(_catalogRepository);
    _searchProductsUseCase = SearchProductsUseCase(_catalogRepository);
    _getProductsByPriceRangeUseCase =
        GetProductsByPriceRangeUseCase(_catalogRepository);
    _getInStockProductsUseCase = GetInStockProductsUseCase(_catalogRepository);
    _getProductDetailUseCase = GetProductDetailUseCase(_catalogRepository);
  }

  static AuthProvider getAuthProvider() {
    return AuthProvider(
      loginUseCase: _loginUseCase,
      signUpUseCase: _signUpUseCase,
      authRepository: _authRepository,
    );
  }

  static StoreProvider getStoreProvider() {
    return StoreProvider(
      registerStoreUseCase: _registerStoreUseCase,
    );
  }

  static DistributorProvider getDistributorProvider() {
    return DistributorProvider(
      registerDistributorUseCase: _registerDistributorUseCase,
    );
  }

  static MatchingProvider getMatchingProvider() {
    return MatchingProvider(
      getRecommendationsUseCase: _getRecommendationsUseCase,
    );
  }

  static QuoteRequestProvider getQuoteRequestProvider() {
    return QuoteRequestProvider(
      createQuoteRequestUseCase: _createQuoteRequestUseCase,
      getStoreQuoteRequestsUseCase: _getStoreQuoteRequestsUseCase,
      getDistributorQuoteRequestsUseCase: _getDistributorQuoteRequestsUseCase,
      respondToQuoteRequestUseCase: _respondToQuoteRequestUseCase,
      completeQuoteRequestUseCase: _completeQuoteRequestUseCase,
      cancelQuoteRequestUseCase: _cancelQuoteRequestUseCase,
    );
  }

  static ComparisonProvider getComparisonProvider() {
    return ComparisonProvider(
      compareTopDistributorsUseCase: _compareTopDistributorsUseCase,
      compareDistributorsUseCase: _compareDistributorsUseCase,
      findBestByCategoryUseCase: _findBestByCategoryUseCase,
    );
  }

  static CatalogProvider getCatalogProvider() {
    return CatalogProvider(
      createProductUseCase: _createProductUseCase,
      getMyProductsUseCase: _getMyProductsUseCase,
      updateProductUseCase: _updateProductUseCase,
      deleteProductUseCase: _deleteProductUseCase,
      updateStockUseCase: _updateStockUseCase,
      toggleAvailabilityUseCase: _toggleAvailabilityUseCase,
      getDistributorCatalogUseCase: _getDistributorCatalogUseCase,
      getProductsByCategoryUseCase: _getProductsByCategoryUseCase,
      searchProductsUseCase: _searchProductsUseCase,
      getProductsByPriceRangeUseCase: _getProductsByPriceRangeUseCase,
      getInStockProductsUseCase: _getInStockProductsUseCase,
      getProductDetailUseCase: _getProductDetailUseCase,
    );
  }
}
