# 품질 이슈 시스템 통합 가이드

## 🔗 기존 앱에 통합하기

### 1단계: Provider 등록

기존 `main.dart`의 Provider 설정에 추가:

```dart
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 품질 이슈 관련 import
import 'data/datasources/quality_issue_remote_datasource.dart';
import 'data/repositories/quality_issue_repository_impl.dart';
import 'domain/usecases/submit_quality_issue.dart';
import 'domain/usecases/get_store_quality_issues.dart';
import 'domain/usecases/get_pending_quality_issues.dart';
import 'domain/usecases/approve_quality_issue.dart';
import 'domain/usecases/reject_quality_issue.dart';
import 'presentation/providers/quality_issue_provider.dart';
import 'presentation/providers/distributor_quality_issue_provider.dart';

void main() {
  // HTTP 클라이언트 생성
  final httpClient = http.Client();
  
  // DataSource 생성
  final qualityIssueDataSource = QualityIssueRemoteDataSourceImpl(
    client: httpClient,
    baseUrl: 'http://localhost:8080', // 실제 서버 URL로 변경
  );
  
  // Repository 생성
  final qualityIssueRepository = QualityIssueRepositoryImpl(
    remoteDataSource: qualityIssueDataSource,
  );
  
  runApp(
    MultiProvider(
      providers: [
        // 기존 Provider들...
        
        // 품질 이슈 Provider 추가
        ChangeNotifierProvider(
          create: (_) => QualityIssueProvider(
            submitQualityIssue: SubmitQualityIssue(qualityIssueRepository),
            getStoreQualityIssues: GetStoreQualityIssues(qualityIssueRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DistributorQualityIssueProvider(
            getPendingQualityIssues: GetPendingQualityIssues(qualityIssueRepository),
            approveQualityIssue: ApproveQualityIssue(qualityIssueRepository),
            rejectQualityIssue: RejectQualityIssue(qualityIssueRepository),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2단계: 인증 토큰 설정

로그인 후 토큰을 DataSource에 설정:

```dart
// 로그인 성공 후
final token = loginResponse.accessToken;

// DataSource에 토큰 설정
final dataSource = context.read<QualityIssueRemoteDataSourceImpl>();
dataSource.setToken(token);

// 또는 SharedPreferences에서 토큰 로드
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('jwt_token');
if (token != null) {
  dataSource.setToken(token);
}
```

### 3단계: 네비게이션 추가

기존 메뉴나 홈 화면에 품질 이슈 메뉴 추가:

```dart
// 가게사장님 메뉴에 추가
ListTile(
  leading: const Icon(Icons.report_problem),
  title: const Text('품질 이슈 관리'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreQualityIssueListPage(
          storeId: currentUser.storeId,
        ),
      ),
    );
  },
),

// 유통업자 메뉴에 추가
ListTile(
  leading: const Icon(Icons.pending_actions),
  title: const Text('대기 중인 품질 이슈'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistributorPendingIssuesPage(
          distributorId: currentUser.distributorId,
        ),
      ),
    );
  },
),
```

## 🔐 인증 통합

### SharedPreferences 사용

```dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    // DataSource에도 설정
    final dataSource = getIt<QualityIssueRemoteDataSourceImpl>();
    dataSource.setToken(token);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

### FlutterSecureStorage 사용 (권장)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureAuthService {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    
    // DataSource에도 설정
    final dataSource = getIt<QualityIssueRemoteDataSourceImpl>();
    dataSource.setToken(token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

## 🎨 테마 통합

기존 앱의 테마 색상을 사용하도록 수정:

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // 품질 이슈 상태 색상
  static const Color submitted = Color(0xFFFF9800);    // 주황색
  static const Color reviewing = Color(0xFF2196F3);    // 파란색
  static const Color approved = Color(0xFF4CAF50);     // 초록색
  static const Color rejected = Color(0xFFF44336);     // 빨간색
  static const Color pickupScheduled = Color(0xFF9C27B0); // 보라색
  static const Color pickedUp = Color(0xFF009688);     // 청록색
  static const Color completed = Color(0xFF3F51B5);    // 남색
}
```

## 📱 주문 화면과 연동

주문 상세 화면에서 품질 이슈 신고 버튼 추가:

```dart
// 주문 상세 화면
class OrderDetailPage extends StatelessWidget {
  final Order order;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주문 상세')),
      body: Column(
        children: [
          // 주문 정보 표시
          // ...
          
          // 품질 이슈 신고 버튼
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubmitQualityIssuePage(
                    storeId: order.storeId,
                    // 주문 정보를 미리 채워서 전달할 수도 있음
                  ),
                ),
              );
            },
            icon: const Icon(Icons.report_problem),
            label: const Text('품질 이슈 신고'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔔 알림 통합

품질 이슈 상태 변경 시 알림:

```dart
// Firebase Cloud Messaging 사용 예시
class NotificationService {
  Future<void> handleQualityIssueNotification(
    Map<String, dynamic> data,
  ) async {
    final issueId = data['issueId'];
    final status = data['status'];
    
    // 로컬 알림 표시
    await showLocalNotification(
      title: '품질 이슈 상태 변경',
      body: '이슈 #$issueId의 상태가 $status(으)로 변경되었습니다.',
    );
    
    // 앱이 포그라운드에 있으면 다이얼로그 표시
    if (isAppInForeground) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('품질 이슈 업데이트'),
          content: Text('이슈 #$issueId의 상태가 변경되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QualityIssueDetailPage(
                      issueId: issueId,
                    ),
                  ),
                );
              },
              child: const Text('상세 보기'),
            ),
          ],
        ),
      );
    }
  }
}
```

## 🧪 테스트 코드 예시

```dart
// test/presentation/providers/quality_issue_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('QualityIssueProvider', () {
    late QualityIssueProvider provider;
    late MockSubmitQualityIssue mockSubmitQualityIssue;
    late MockGetStoreQualityIssues mockGetStoreQualityIssues;
    
    setUp(() {
      mockSubmitQualityIssue = MockSubmitQualityIssue();
      mockGetStoreQualityIssues = MockGetStoreQualityIssues();
      
      provider = QualityIssueProvider(
        submitQualityIssue: mockSubmitQualityIssue,
        getStoreQualityIssues: mockGetStoreQualityIssues,
      );
    });
    
    test('품질 이슈 신고 성공', () async {
      // Given
      final issue = QualityIssue(...);
      when(mockSubmitQualityIssue(...))
          .thenAnswer((_) async => Right(issue));
      
      // When
      final result = await provider.submitIssue(...);
      
      // Then
      expect(result, true);
      expect(provider.issues.length, 1);
      expect(provider.errorMessage, null);
    });
  });
}
```

## 📊 분석 및 로깅

```dart
// 품질 이슈 신고 시 분석 이벤트 전송
class AnalyticsService {
  Future<void> logQualityIssueSubmitted({
    required String issueType,
    required String requestAction,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'quality_issue_submitted',
      parameters: {
        'issue_type': issueType,
        'request_action': requestAction,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logQualityIssueApproved(int issueId) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'quality_issue_approved',
      parameters: {
        'issue_id': issueId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## 🌐 다국어 지원

```dart
// lib/l10n/app_ko.arb
{
  "qualityIssueTitle": "품질 이슈 관리",
  "submitIssue": "품질 이슈 신고",
  "issueTypePoorQuality": "품질 불량",
  "issueTypeWrongItem": "오배송",
  "issueTypeDamaged": "파손",
  "issueTypeExpired": "유통기한 임박/경과",
  "issueTypeQuantityMismatch": "수량 불일치",
  "requestActionRefund": "환불",
  "requestActionExchange": "교환",
  "statusSubmitted": "접수됨",
  "statusReviewing": "검토 중",
  "statusApproved": "승인됨",
  "statusRejected": "거절됨"
}
```

## 🔄 상태 관리 대안

### Riverpod 사용 시

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qualityIssueRepositoryProvider = Provider<QualityIssueRepository>((ref) {
  return QualityIssueRepositoryImpl(
    remoteDataSource: ref.watch(qualityIssueDataSourceProvider),
  );
});

final storeIssuesProvider = FutureProvider.family<List<QualityIssue>, String>(
  (ref, storeId) async {
    final repository = ref.watch(qualityIssueRepositoryProvider);
    final result = await repository.getStoreIssues(storeId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (issues) => issues,
    );
  },
);
```

### Bloc 사용 시

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class QualityIssueBloc extends Bloc<QualityIssueEvent, QualityIssueState> {
  final SubmitQualityIssue submitQualityIssue;
  final GetStoreQualityIssues getStoreQualityIssues;
  
  QualityIssueBloc({
    required this.submitQualityIssue,
    required this.getStoreQualityIssues,
  }) : super(QualityIssueInitial()) {
    on<LoadStoreIssues>(_onLoadStoreIssues);
    on<SubmitIssue>(_onSubmitIssue);
  }
  
  Future<void> _onLoadStoreIssues(
    LoadStoreIssues event,
    Emitter<QualityIssueState> emit,
  ) async {
    emit(QualityIssueLoading());
    final result = await getStoreQualityIssues(event.storeId);
    result.fold(
      (failure) => emit(QualityIssueError(failure.message)),
      (issues) => emit(QualityIssueLoaded(issues)),
    );
  }
}
```

## 📝 체크리스트

통합 완료 후 다음 항목을 확인하세요:

- [ ] Provider 등록 완료
- [ ] 인증 토큰 설정 완료
- [ ] 네비게이션 추가 완료
- [ ] 테마 색상 통합 완료
- [ ] 주문 화면과 연동 완료
- [ ] 알림 설정 완료 (선택)
- [ ] 분석 이벤트 추가 완료 (선택)
- [ ] 다국어 지원 완료 (선택)
- [ ] 테스트 코드 작성 완료 (선택)

---

**작성일**: 2025-11-30
**버전**: 1.0.0
