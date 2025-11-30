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
import 'package:fresh_flow/data/datasources/cart_remote_datasource.dart';
import 'package:fresh_flow/data/datasources/order_remote_data_source.dart';
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
import 'package:fresh_flow/domain/repositories/cart_repository.dart';
import 'package:fresh_flow/data/repositories/cart_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/order_repository.dart';
import 'package:fresh_flow/data/repositories/order_repository_impl.dart';
import 'package:fresh_flow/domain/usecases/login_usecase.dart';
import 'package:fresh_flow/domain/usecases/signup_usecase.dart';
import 'package:fresh_flow/domain/usecases/register_store_usecase.dart';
import 'package:fresh_flow/domain/usecases/get_store_info_usecase.dart';
import 'package:fresh_flow/domain/usecases/register_distributor_usecase.dart';
import 'package:fresh_flow/domain/usecases/get_recommendations_usecase.dart';
import 'package:fresh_flow/domain/usecases/quote_request_usecases.dart';
import 'package:fresh_flow/domain/usecases/comparison_usecases.dart';
import 'package:fresh_flow/domain/usecases/catalog_usecases.dart';
import 'package:fresh_flow/domain/usecases/cart_usecases.dart';
import 'package:fresh_flow/domain/usecases/order_usecases.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/store_provider.dart';
import 'package:fresh_flow/presentation/providers/distributor_provider.dart';
import 'package:fresh_flow/presentation/providers/matching_provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/presentation/providers/comparison_provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';
import 'package:fresh_flow/presentation/providers/cart_provider.dart';
import 'package:fresh_flow/presentation/providers/order_provider.dart';
import 'package:fresh_flow/data/datasources/chat_remote_data_source.dart';
import 'package:fresh_flow/data/datasources/chat_remote_data_source_impl.dart';
import 'package:fresh_flow/data/datasources/websocket_data_source.dart';
import 'package:fresh_flow/data/datasources/websocket_data_source_impl.dart';
import 'package:fresh_flow/data/repositories/chat_repository_impl.dart';
import 'package:fresh_flow/data/repositories/websocket_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/chat_repository.dart';
import 'package:fresh_flow/domain/repositories/websocket_repository.dart';
import 'package:fresh_flow/domain/usecases/get_chat_rooms.dart';
import 'package:fresh_flow/domain/usecases/create_or_get_chat_room.dart';
import 'package:fresh_flow/domain/usecases/get_messages.dart';
import 'package:fresh_flow/domain/usecases/mark_messages_as_read.dart';
import 'package:fresh_flow/domain/usecases/send_message.dart';
import 'package:fresh_flow/presentation/providers/chat_provider.dart';
import 'package:fresh_flow/data/datasources/delivery_remote_datasource.dart';
import 'package:fresh_flow/presentation/providers/delivery_provider.dart';
import 'package:fresh_flow/data/datasources/review_remote_datasource.dart';
import 'package:fresh_flow/presentation/providers/review_provider.dart';
import 'package:fresh_flow/data/datasources/group_buying_remote_data_source.dart';
import 'package:fresh_flow/data/repositories/group_buying_repository_impl.dart';
import 'package:fresh_flow/domain/repositories/group_buying_repository.dart';
import 'package:fresh_flow/domain/usecases/get_open_rooms.dart';
import 'package:fresh_flow/domain/usecases/get_room_detail.dart';
import 'package:fresh_flow/domain/usecases/join_room.dart';
import 'package:fresh_flow/domain/usecases/get_store_participations.dart';
import 'package:fresh_flow/presentation/providers/group_buying_provider.dart';
import 'package:fresh_flow/domain/usecases/create_room.dart';
import 'package:fresh_flow/domain/usecases/get_distributor_rooms.dart';
import 'package:fresh_flow/domain/usecases/open_room.dart';
import 'package:fresh_flow/presentation/providers/distributor_group_buying_provider.dart';
import 'package:fresh_flow/data/datasources/settlement_remote_datasource.dart';
import 'package:fresh_flow/presentation/providers/settlement_provider.dart';

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
  static late GetStoreInfoUseCase _getStoreInfoUseCase;
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
  static late CreateOrUpdateDeliveryInfoUseCase _createOrUpdateDeliveryInfoUseCase;
  static late GetProductDetailWithDeliveryUseCase _getProductDetailWithDeliveryUseCase;
  static late CartRemoteDataSource _cartRemoteDataSource;
  static late CartRepository _cartRepository;
  static late OrderRemoteDataSource _orderRemoteDataSource;
  static late OrderRepository _orderRepository;
  static late AddToCartUseCase _addToCartUseCase;
  static late GetCartUseCase _getCartUseCase;
  static late UpdateCartItemQuantityUseCase _updateCartItemQuantityUseCase;
  static late RemoveCartItemUseCase _removeCartItemUseCase;
  static late ClearCartUseCase _clearCartUseCase;
  static late CreateOrderUseCase _createOrderUseCase;
  static late GetOrdersUseCase _getOrdersUseCase;
  static late GetDistributorOrdersUseCase _getDistributorOrdersUseCase;
  static late GetOrderByIdUseCase _getOrderByIdUseCase;
  static late CancelOrderUseCase _cancelOrderUseCase;
  static late ConfirmPaymentUseCase _confirmPaymentUseCase;
  static late ConfirmOrderUseCase _confirmOrderUseCase;
  static late ChatRemoteDataSource _chatRemoteDataSource;
  static late WebSocketDataSource _webSocketDataSource;
  static late ChatRepository _chatRepository;
  static late WebSocketRepository _webSocketRepository;
  static late GetChatRooms _getChatRooms;
  static late CreateOrGetChatRoom _createOrGetChatRoom;
  static late GetMessages _getMessages;
  static late MarkMessagesAsRead _markMessagesAsRead;
  static late SendMessage _sendMessage;
  static late DeliveryRemoteDataSource _deliveryRemoteDataSource;
  static late ReviewRemoteDataSource _reviewRemoteDataSource;
  static late GroupBuyingRemoteDataSource _groupBuyingRemoteDataSource;
  static late GroupBuyingRepository _groupBuyingRepository;
  static late GetOpenRooms _getOpenRooms;
  static late GetRoomDetail _getRoomDetail;
  static late JoinRoom _joinRoom;
  static late GetStoreParticipations _getStoreParticipations;
  static late CreateRoom _createRoom;
  static late GetDistributorRooms _getDistributorRooms;
  static late OpenRoom _openRoom;
  static late SettlementRemoteDataSource _settlementRemoteDataSource;

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
    _cartRemoteDataSource = CartRemoteDataSourceImpl(_httpClient);
    _orderRemoteDataSource = OrderRemoteDataSourceImpl(_httpClient);
    _chatRemoteDataSource = ChatRemoteDataSourceImpl(
      client: _httpClient,
      getAccessToken: () => _authRepository.getAccessToken(),
    );
    _webSocketDataSource = WebSocketDataSourceImpl();
    _deliveryRemoteDataSource = DeliveryRemoteDataSourceImpl(_httpClient);
    _reviewRemoteDataSource = ReviewRemoteDataSourceImpl(_httpClient);
    _groupBuyingRemoteDataSource = GroupBuyingRemoteDataSourceImpl(client: _httpClient);
    _settlementRemoteDataSource = SettlementRemoteDataSourceImpl(_httpClient);

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
    _cartRepository = CartRepositoryImpl(
      remoteDataSource: _cartRemoteDataSource,
      authRepository: _authRepository,
    );
    _orderRepository = OrderRepositoryImpl(
      remoteDataSource: _orderRemoteDataSource,
      authRepository: _authRepository,
    );
    _chatRepository = ChatRepositoryImpl(
      remoteDataSource: _chatRemoteDataSource,
      webSocketDataSource: _webSocketDataSource,
    );
    _webSocketRepository = WebSocketRepositoryImpl(
      dataSource: _webSocketDataSource,
    );
    _groupBuyingRepository = GroupBuyingRepositoryImpl(
      remoteDataSource: _groupBuyingRemoteDataSource,
    );

    // Use cases
    _loginUseCase = LoginUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _registerStoreUseCase = RegisterStoreUseCase(_storeRepository);
    _getStoreInfoUseCase = GetStoreInfoUseCase(_storeRepository);
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
    _createOrUpdateDeliveryInfoUseCase = CreateOrUpdateDeliveryInfoUseCase(_catalogRepository);
    _getProductDetailWithDeliveryUseCase = GetProductDetailWithDeliveryUseCase(_catalogRepository);
    _addToCartUseCase = AddToCartUseCase(_cartRepository);
    _getCartUseCase = GetCartUseCase(_cartRepository);
    _updateCartItemQuantityUseCase = UpdateCartItemQuantityUseCase(_cartRepository);
    _removeCartItemUseCase = RemoveCartItemUseCase(_cartRepository);
    _clearCartUseCase = ClearCartUseCase(_cartRepository);
    _createOrderUseCase = CreateOrderUseCase(_orderRepository);
    _getOrdersUseCase = GetOrdersUseCase(_orderRepository);
    _getDistributorOrdersUseCase = GetDistributorOrdersUseCase(_orderRepository);
    _getOrderByIdUseCase = GetOrderByIdUseCase(_orderRepository);
    _cancelOrderUseCase = CancelOrderUseCase(_orderRepository);
    _confirmPaymentUseCase = ConfirmPaymentUseCase(_orderRepository);
    _confirmOrderUseCase = ConfirmOrderUseCase(_orderRepository);
    _getChatRooms = GetChatRooms(_chatRepository);
    _createOrGetChatRoom = CreateOrGetChatRoom(_chatRepository);
    _getMessages = GetMessages(_chatRepository);
    _markMessagesAsRead = MarkMessagesAsRead(_chatRepository);
    _sendMessage = SendMessage(_chatRepository);
    _getOpenRooms = GetOpenRooms(_groupBuyingRepository);
    _getRoomDetail = GetRoomDetail(_groupBuyingRepository);
    _joinRoom = JoinRoom(_groupBuyingRepository);
    _getStoreParticipations = GetStoreParticipations(_groupBuyingRepository);
    _createRoom = CreateRoom(_groupBuyingRepository);
    _getDistributorRooms = GetDistributorRooms(_groupBuyingRepository);
    _openRoom = OpenRoom(_groupBuyingRepository);
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
      getStoreInfoUseCase: _getStoreInfoUseCase,
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
      createOrUpdateDeliveryInfoUseCase: _createOrUpdateDeliveryInfoUseCase,
      getProductDetailWithDeliveryUseCase: _getProductDetailWithDeliveryUseCase,
    );
  }

  static CartProvider getCartProvider() {
    return CartProvider(
      addToCartUseCase: _addToCartUseCase,
      getCartUseCase: _getCartUseCase,
      updateCartItemQuantityUseCase: _updateCartItemQuantityUseCase,
      removeCartItemUseCase: _removeCartItemUseCase,
      clearCartUseCase: _clearCartUseCase,
    );
  }

  static OrderProvider getOrderProvider() {
    return OrderProvider(
      createOrderUseCase: _createOrderUseCase,
      getOrdersUseCase: _getOrdersUseCase,
      getDistributorOrdersUseCase: _getDistributorOrdersUseCase,
      getOrderByIdUseCase: _getOrderByIdUseCase,
      cancelOrderUseCase: _cancelOrderUseCase,
      confirmPaymentUseCase: _confirmPaymentUseCase,
      confirmOrderUseCase: _confirmOrderUseCase,
    );
  }

  static ChatProvider getChatProvider() {
    return ChatProvider(
      getChatRooms: _getChatRooms,
      createOrGetChatRoom: _createOrGetChatRoom,
      getMessages: _getMessages,
      markMessagesAsRead: _markMessagesAsRead,
      sendMessage: _sendMessage,
      webSocketRepository: _webSocketRepository,
    );
  }

  static DeliveryProvider getDeliveryProvider() {
    return DeliveryProvider(
      remoteDataSource: _deliveryRemoteDataSource,
      authRepository: _authRepository,
    );
  }

  static ReviewProvider getReviewProvider() {
    return ReviewProvider(
      remoteDataSource: _reviewRemoteDataSource,
      authRepository: _authRepository,
    );
  }

  static GroupBuyingProvider getGroupBuyingProvider() {
    return GroupBuyingProvider(
      getOpenRooms: _getOpenRooms,
      getRoomDetail: _getRoomDetail,
      joinRoom: _joinRoom,
      getStoreParticipations: _getStoreParticipations,
    );
  }

  static DistributorGroupBuyingProvider getDistributorGroupBuyingProvider() {
    return DistributorGroupBuyingProvider(
      createRoom: _createRoom,
      getDistributorRooms: _getDistributorRooms,
      openRoom: _openRoom,
    );
  }

  static SettlementProvider getSettlementProvider() {
    return SettlementProvider(_settlementRemoteDataSource, _authRepository);
  }
}
