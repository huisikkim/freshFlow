class ApiConstants {
  // 개발 환경 설정
  static const bool isDevelopment = true; // 로컬 개발시 true, 배포시 false로 변경
  
  // 로컬 개발 URL
  // - Android 에뮬레이터: 10.0.2.2
  // - iOS 시뮬레이터: localhost
  // - 실제 기기: Mac의 실제 IP 주소 (예: 192.168.45.80)
  //static const String localBaseUrl = 'http://192.168.45.80:8080'; // 실제 기기용
  static const String localBaseUrl = 'http://localhost:8080';
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
  
  // 토스페이먼츠 클라이언트 키
  static const String tossPaymentsClientKey = 'test_ck_kYG57Eba3Gp9GBALzABLVpWDOxmA';
}
