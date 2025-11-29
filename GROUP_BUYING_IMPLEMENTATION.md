# 공동구매 기능 구현 완료

## 📁 구현된 파일 구조

```
lib/
├── domain/
│   ├── entities/
│   │   ├── group_buying_room.dart              # 공동구매 방 엔티티
│   │   ├── group_buying_participant.dart       # 참여자 엔티티
│   │   └── group_buying_statistics.dart        # 통계 엔티티
│   ├── repositories/
│   │   └── group_buying_repository.dart        # Repository 인터페이스
│   └── usecases/
│       ├── get_open_rooms.dart                 # 오픈 방 조회
│       ├── get_room_detail.dart                # 방 상세 조회
│       ├── join_room.dart                      # 방 참여
│       └── get_store_participations.dart       # 참여 내역 조회
├── data/
│   ├── models/
│   │   ├── group_buying_room_model.dart        # 방 모델
│   │   ├── group_buying_participant_model.dart # 참여자 모델
│   │   └── group_buying_statistics_model.dart  # 통계 모델
│   ├── datasources/
│   │   └── group_buying_remote_data_source.dart # API 통신
│   └── repositories/
│       └── group_buying_repository_impl.dart   # Repository 구현
└── presentation/
    ├── providers/
    │   └── group_buying_provider.dart          # 상태 관리
    └── pages/
        ├── group_buying_list_page.dart         # 공동구매 목록
        ├── group_buying_detail_page.dart       # 공동구매 상세
        └── group_buying_my_participations_page.dart # 내 참여 내역
```

## 🎯 구현된 기능

### 1. 공동구매 방 조회 (가게)
- ✅ 오픈 중인 방 목록 조회
- ✅ 방 상세 정보 조회
- ✅ 추천 방 조회
- ✅ 마감 임박 방 조회
- ✅ 지역/카테고리 필터링

### 2. 공동구매 참여 (가게)
- ✅ 공동구매 참여
- ✅ 참여 취소
- ✅ 내 참여 내역 조회
- ✅ 방의 참여자 목록 조회

### 3. 공동구매 방 관리 (유통업자)
- ✅ 방 생성
- ✅ 방 오픈
- ✅ 방 수동 마감
- ✅ 방 취소
- ✅ 유통업자의 방 목록 조회

### 4. 통계 API
- ✅ 유통업자 통계
- ✅ 가게 통계
- ✅ 시스템 통계

## 📱 UI 페이지

### 1. GroupBuyingListPage
공동구매 목록을 보여주는 페이지
- 진행 중인 공동구매 목록
- 할인율, 달성률, 남은 시간 표시
- 추천 배지 표시
- Pull to refresh 지원

### 2. GroupBuyingDetailPage
공동구매 상세 정보 및 참여 페이지
- 상세 정보 표시
- 가격 정보 (정가, 할인가, 절약 금액)
- 진행 현황 (달성률, 참여자 수)
- 참여 폼 (수량, 배송지, 연락처, 요청사항)

### 3. GroupBuyingMyParticipationsPage
내 참여 내역 페이지
- 참여한 공동구매 목록
- 상태별 표시 (참여중, 확정, 주문생성, 배송완료, 취소)
- 금액 정보 (상품 금액, 배송비, 총 금액, 절약 금액)

## 🔧 사용 방법

### 1. 공동구매 목록 페이지로 이동

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const GroupBuyingListPage(),
  ),
);
```

### 2. 내 참여 내역 페이지로 이동

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GroupBuyingMyParticipationsPage(
      storeId: 'STORE001', // 실제 storeId 사용
    ),
  ),
);
```

### 3. Provider 사용 예제

```dart
// 오픈 방 목록 조회
final provider = context.read<GroupBuyingProvider>();
await provider.fetchOpenRooms();

// 지역 필터링
await provider.fetchOpenRooms(region: '강남구');

// 방 상세 조회
await provider.fetchRoomDetail('GBR-20231129143022-1234');

// 공동구매 참여
final success = await provider.joinGroupBuying(
  roomId: 'GBR-20231129143022-1234',
  storeId: 'STORE001',
  quantity: 30,
  deliveryAddress: '서울시 강남구 테헤란로 123',
  deliveryPhone: '010-1234-5678',
  deliveryRequest: '문 앞에 놓아주세요',
);

// 내 참여 내역 조회
await provider.fetchMyParticipations('STORE001');
```

## 🌐 API 엔드포인트

Base URL: `http://localhost:8080/api/group-buying`

모든 API는 `GroupBuyingRemoteDataSource`에 구현되어 있습니다.

### 주요 엔드포인트
- `GET /rooms/open` - 오픈 방 목록
- `GET /rooms/{roomId}` - 방 상세
- `POST /participants/join` - 참여하기
- `GET /participants/store/{storeId}` - 내 참여 내역
- `POST /rooms` - 방 생성 (유통업자)
- `POST /rooms/{roomId}/open` - 방 오픈 (유통업자)

## 📝 주요 데이터 모델

### RoomStatus (방 상태)
- `WAITING` - 대기 중
- `OPEN` - 오픈
- `CLOSED_SUCCESS` - 마감 성공
- `CLOSED_FAILED` - 마감 실패
- `ORDER_CREATED` - 주문 생성
- `COMPLETED` - 완료
- `CANCELLED` - 취소

### ParticipantStatus (참여자 상태)
- `JOINED` - 참여 완료
- `CONFIRMED` - 확정됨
- `ORDER_CREATED` - 주문 생성됨
- `DELIVERED` - 배송 완료
- `CANCELLED` - 취소됨

### DeliveryFeeType (배송비 타입)
- `FREE` - 무료 배송
- `FIXED` - 고정 배송비
- `SHARED` - 분담 배송비

## ✅ Clean Architecture 준수

이 구현은 Clean Architecture 원칙을 따릅니다:

1. **Domain Layer** (비즈니스 로직)
   - Entities: 핵심 비즈니스 객체
   - Repositories: 인터페이스 정의
   - Use Cases: 비즈니스 로직 실행

2. **Data Layer** (데이터 처리)
   - Models: JSON 직렬화/역직렬화
   - Data Sources: API 통신
   - Repository Implementations: 인터페이스 구현

3. **Presentation Layer** (UI)
   - Providers: 상태 관리 (ChangeNotifier)
   - Pages: UI 화면
   - Widgets: 재사용 가능한 UI 컴포넌트

## 🔄 의존성 주입

`InjectionContainer`에 모든 의존성이 등록되어 있습니다:
- Data Sources
- Repositories
- Use Cases
- Providers

## 🚀 다음 단계

필요에 따라 추가 구현 가능한 기능:
1. 유통업자용 방 관리 UI
2. 실시간 업데이트 (WebSocket)
3. 알림 기능
4. 검색 및 정렬 기능
5. 즐겨찾기 기능
6. 공유 기능

## 📌 참고사항

- 현재 `storeId`는 하드코딩되어 있습니다 (`STORE001`). 실제 사용 시 로그인한 사용자의 ID를 사용해야 합니다.
- API 서버가 `http://localhost:8080`에서 실행 중이어야 합니다.
- 모든 API 호출은 에러 처리가 구현되어 있습니다.
