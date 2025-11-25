class ApiConstants {
  // 개발 환경 설정
  static const bool isDevelopment = true; // 로컬 개발시 true, 배포시 false로 변경
  
  // 로컬 개발 URL (Android 에뮬레이터: 10.0.2.2, iOS 시뮬레이터: localhost)
//static const String localBaseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터용
   static const String localBaseUrl = 'http://localhost:8080';
  
  // 프로덕션 URL
  static const String productionBaseUrl = 'https://port-0-payflow-rm6l2llvxxefd7.sel5.cloudtype.app';
  
  // 현재 사용할 Base URL
  static String get baseUrl => isDevelopment ? localBaseUrl : productionBaseUrl;
  
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
}
