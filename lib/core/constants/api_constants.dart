class ApiConstants {
  // 개발 환경 설정
  static const bool isDevelopment = true; // 로컬 개발시 true, 배포시 false로 변경
  
  // 로컬 개발 URL
  //static const String localBaseUrl = 'http://192.168.45.80:8080'; // 안드로이드
  static const String localBaseUrl = 'http://localhost:8080'; // ios
  // 개발 URL
  static const String devBaseUrl = 'https://port-0-payflow-rm6l2llvxxefd7.sel5.cloudtype.app';
  
  // 현재 사용할 Base URL
  static String get baseUrl => isDevelopment ? localBaseUrl : devBaseUrl;
  
  // WebSocket URL
  static String get wsUrl => isDevelopment 
      ? localBaseUrl.replaceFirst('http', 'ws')
      : devBaseUrl.replaceFirst('https', 'wss');
  
  // API 엔드포인트
  static const String loginEndpoint = '/api/auth/login';
  static const String signUpEndpoint = '/api/auth/signup';
  static const String profileEndpoint = '/api/user/profile';
  static const String storeInfoEndpoint = '/api/store/info';
  static const String distributorInfoEndpoint = '/api/distributor/info';
  static const String matchingRecommendEndpoint = '/api/matching/recommend';
  static const String quoteRequestEndpoint = '/api/matching/quote-request';
  static const String storeQuoteRequestsEndpoint =
      '/api/matching/quote-requests/store';
  static const String distributorQuoteRequestsEndpoint =
      '/api/matching/quote-requests/distributor';
  static const String compareTopEndpoint = '/api/matching/compare/top';
  static const String compareEndpoint = '/api/matching/compare';
  static const String compareBestByCategoryEndpoint =
      '/api/matching/compare/best-by-category';
  static const String catalogProductsEndpoint = '/api/catalog/products';
  static const String catalogMyProductsEndpoint = '/api/catalog/my-products';
  
  // 결제 관련 엔드포인트
  static const String paymentConfirmEndpoint = '/api/payments/confirm';
  
  // 주문 확정 엔드포인트 (orderNumber 사용 - 권장)
  static String orderConfirmEndpoint(String orderNumber) => '/api/catalog-orders/confirm/$orderNumber';
  
  // 배송 관련 엔드포인트
  static const String deliveriesStoreEndpoint = '/api/deliveries/store';
  static String deliveryByOrderEndpoint(String orderId) => '/api/deliveries/order/$orderId';
  static String createDeliveryEndpoint(String orderId) => '/api/deliveries/order/$orderId';
  static String shipDeliveryEndpoint(String orderId) => '/api/deliveries/order/$orderId/ship';
  static String completeDeliveryEndpoint(String orderId) => '/api/deliveries/order/$orderId/complete';
  
  // 리뷰 관련 엔드포인트
  static const String createStoreReviewEndpoint = '/api/reviews/store';
  static const String createDistributorReviewEndpoint = '/api/reviews/distributor';
  static const String reviewStatisticsEndpoint = '/api/reviews/statistics';
  
  // 토스페이먼츠 클라이언트 키
  static const String tossPaymentsClientKey = 'test_ck_kYG57Eba3Gp9GBALzABLVpWDOxmA';
}
