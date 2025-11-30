# 품질 이슈 시스템 Flutter 구현 완료

## 📁 구현된 파일 구조

```
lib/
├── domain/
│   ├── entities/
│   │   └── quality_issue.dart              # 품질 이슈 엔티티 (Enum 포함)
│   ├── repositories/
│   │   └── quality_issue_repository.dart   # Repository 인터페이스
│   └── usecases/
│       ├── submit_quality_issue.dart       # 품질 이슈 신고
│       ├── get_quality_issue.dart          # 이슈 상세 조회
│       ├── get_store_quality_issues.dart   # 가게별 이슈 목록
│       ├── get_pending_quality_issues.dart # 대기 중인 이슈 목록
│       ├── approve_quality_issue.dart      # 이슈 승인
│       └── reject_quality_issue.dart       # 이슈 거절
├── data/
│   ├── models/
│   │   └── quality_issue_model.dart        # 데이터 모델
│   ├── datasources/
│   │   └── quality_issue_remote_datasource.dart  # API 통신
│   └── repositories/
│       └── quality_issue_repository_impl.dart    # Repository 구현
└── presentation/
    ├── providers/
    │   ├── quality_issue_provider.dart              # 가게사장님용 Provider
    │   └── distributor_quality_issue_provider.dart  # 유통업자용 Provider
    └── pages/
        └── quality_issue/
            ├── quality_issue_example_page.dart      # 테스트용 메인 페이지
            ├── store_quality_issue_list_page.dart   # 가게사장님 목록
            ├── submit_quality_issue_page.dart       # 품질 이슈 신고
            ├── quality_issue_detail_page.dart       # 이슈 상세 (기본 구조)
            └── distributor_pending_issues_page.dart # 유통업자 대기 목록
```

## ✅ 구현된 기능

### 1. Domain Layer (비즈니스 로직)
- ✅ QualityIssue 엔티티 정의
- ✅ IssueType, RequestAction, IssueStatus Enum
- ✅ Repository 인터페이스
- ✅ 6개 UseCase 구현

### 2. Data Layer (데이터 처리)
- ✅ QualityIssueModel (JSON 직렬화/역직렬화)
- ✅ Remote DataSource (11개 API 엔드포인트)
- ✅ Repository 구현체

### 3. Presentation Layer (UI)
- ✅ 가게사장님용 Provider
- ✅ 유통업자용 Provider
- ✅ 품질 이슈 목록 페이지
- ✅ 품질 이슈 신고 페이지
- ✅ 유통업자 대기 목록 페이지
- ✅ 상태별 색상 구분
- ✅ 아이콘 표시

## 🚀 사용 방법

### 1. 의존성 확인
이미 `pubspec.yaml`에 필요한 패키지가 모두 포함되어 있습니다:
- ✅ http: ^1.2.0
- ✅ provider: ^6.1.1
- ✅ intl: ^0.19.0
- ✅ dartz: ^0.10.1
- ✅ equatable: ^2.0.5

### 2. 테스트 페이지 실행

`main.dart`에 다음과 같이 추가하세요:

```dart
import 'package:flutter/material.dart';
import 'presentation/pages/quality_issue/quality_issue_example_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Flow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QualityIssueExamplePage(),
    );
  }
}
```

### 3. Provider 설정 (필요 시)

실제 앱에서 사용하려면 Provider를 설정해야 합니다:

```dart
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QualityIssueProvider(
            submitQualityIssue: SubmitQualityIssue(
              QualityIssueRepositoryImpl(
                remoteDataSource: QualityIssueRemoteDataSourceImpl(
                  client: http.Client(),
                  baseUrl: 'http://localhost:8080',
                ),
              ),
            ),
            getStoreQualityIssues: GetStoreQualityIssues(
              QualityIssueRepositoryImpl(
                remoteDataSource: QualityIssueRemoteDataSourceImpl(
                  client: http.Client(),
                  baseUrl: 'http://localhost:8080',
                ),
              ),
            ),
          ),
        ),
        // 유통업자용 Provider도 동일하게 추가
      ],
      child: const MyApp(),
    ),
  );
}
```

## 📱 화면 구성

### 가게사장님 화면
1. **품질 이슈 목록** (`StoreQualityIssueListPage`)
   - 내 가게의 모든 품질 이슈 표시
   - 상태별 색상 구분
   - 새로고침 기능
   - 플로팅 버튼으로 신고 화면 이동

2. **품질 이슈 신고** (`SubmitQualityIssuePage`)
   - 주문 정보 입력
   - 이슈 유형 선택 (5가지)
   - 요청 액션 선택 (환불/교환)
   - 사진 URL 추가
   - 상세 설명 입력

### 유통업자 화면
1. **대기 중인 이슈** (`DistributorPendingIssuesPage`)
   - 처리 대기 중인 이슈 목록
   - 사진 확인
   - 승인/거절 버튼
   - 코멘트 입력 다이얼로그

## 🎨 상태별 색상

```dart
SUBMITTED (접수됨)         → 주황색 (Orange)
REVIEWING (검토 중)        → 파란색 (Blue)
APPROVED (승인됨)          → 초록색 (Green)
REJECTED (거절됨)          → 빨간색 (Red)
PICKUP_SCHEDULED (수거 예정) → 보라색 (Purple)
PICKED_UP (수거 완료)      → 청록색 (Teal)
REFUNDED (환불 완료)       → 남색 (Indigo)
EXCHANGED (교환 완료)      → 남색 (Indigo)
```

## 🔧 추가 구현 필요 사항

### 1. 인증 토큰 관리
현재 DataSource에 `setToken()` 메서드가 있지만, 실제 토큰 관리는 구현되지 않았습니다.

```dart
// 로그인 후 토큰 설정 예시
final dataSource = QualityIssueRemoteDataSourceImpl(...);
dataSource.setToken('your-jwt-token');
```

### 2. 이슈 상세 페이지
`QualityIssueDetailPage`는 기본 구조만 있습니다. 다음을 추가하세요:
- 이슈 전체 정보 표시
- 사진 갤러리
- 상태 변경 히스토리
- 코멘트 표시

### 3. 수거 예약 기능
유통업자가 수거 시간을 예약하는 기능:
- DateTimePicker 추가
- `schedulePickup` API 호출

### 4. 완료 처리 기능
- 수거 완료 처리
- 환불/교환 완료 처리
- 완료 노트 입력

### 5. 실제 이미지 업로드
현재는 URL 문자열만 입력합니다. 실제 구현 시:
- `image_picker` 패키지 사용
- 이미지 서버 또는 S3에 업로드
- 업로드된 URL을 API에 전달

## 🧪 테스트 방법

### 1. 백엔드 서버 실행
```bash
cd payFlow
./gradlew bootRun
```

### 2. Flutter 앱 실행
```bash
flutter run
```

### 3. 테스트 데이터
```
가게 ID: STORE_001
유통사 ID: DIST_001
주문 ID: 123
품목 ID: 456
사진 URL: https://example.com/photo1.jpg
```

## 📝 API 엔드포인트

모든 API는 `http://localhost:8080` 기준입니다:

| API | 메서드 | 엔드포인트 |
|-----|--------|-----------|
| 신고 | POST | `/api/quality-issues` |
| 상세 조회 | GET | `/api/quality-issues/{id}` |
| 가게별 목록 | GET | `/api/quality-issues/store/{storeId}` |
| 대기 목록 | GET | `/api/quality-issues/distributor/{distributorId}/pending` |
| 전체 목록 | GET | `/api/quality-issues/distributor/{distributorId}` |
| 검토 시작 | POST | `/api/quality-issues/{id}/review` |
| 승인 | POST | `/api/quality-issues/{id}/approve` |
| 거절 | POST | `/api/quality-issues/{id}/reject` |
| 수거 예약 | POST | `/api/quality-issues/{id}/schedule-pickup` |
| 수거 완료 | POST | `/api/quality-issues/{id}/complete-pickup` |
| 완료 처리 | POST | `/api/quality-issues/{id}/complete-resolution` |

## 🎯 다음 단계

1. **인증 시스템 통합**
   - 로그인 기능과 연동
   - JWT 토큰 자동 관리

2. **상세 페이지 완성**
   - 전체 정보 표시
   - 사진 갤러리
   - 상태 히스토리

3. **유통업자 기능 완성**
   - 수거 예약 UI
   - 완료 처리 UI
   - 전체 이슈 목록

4. **이미지 업로드**
   - 카메라/갤러리에서 선택
   - 서버에 업로드
   - 썸네일 표시

5. **알림 기능**
   - 푸시 알림
   - 상태 변경 알림

## 📚 참고 문서

- [FLUTTER_QUALITY_ISSUE_API.md](./FLUTTER_QUALITY_ISSUE_API.md) - 전체 API 문서
- [FLUTTER_QUALITY_ISSUE_QUICK_START.md](./FLUTTER_QUALITY_ISSUE_QUICK_START.md) - 빠른 시작
- [QUALITY_ISSUE_GUIDE.md](./QUALITY_ISSUE_GUIDE.md) - 백엔드 가이드

---

**구현 완료일**: 2025-11-30
**Flutter 버전**: 3.10.1+
**아키텍처**: Clean Architecture (Domain, Data, Presentation)
