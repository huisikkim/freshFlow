# 유통업자 공동구매 관리 가이드

## 📱 새로 추가된 페이지

### 1. DistributorGroupBuyingPage
유통업자가 자신이 생성한 공동구매 방을 관리하는 페이지

**기능:**
- 내가 만든 공동구매 방 목록 조회
- 방 상태별 표시 (대기중, 오픈, 마감성공, 마감실패 등)
- 대기중인 방 오픈하기
- 실시간 진행 현황 확인 (달성률, 참여자 수, 남은 시간)

### 2. CreateGroupBuyingRoomPage
새로운 공동구매 방을 생성하는 페이지

**입력 항목:**
- **기본 정보**: 방 제목, 상품 ID
- **가격 및 할인**: 할인율
- **재고 및 목표**: 준비한 재고, 목표 수량
- **주문 제한**: 최소/최대 주문 수량, 최소/최대 참여자 수
- **배송 정보**: 대상 지역, 배송비, 배송비 타입
- **기간 설정**: 진행 시간 (시간 단위)
- **추가 정보**: 설명, 특이사항, 추천 방 설정

## 🚀 사용 방법

### 1. 유통업자 공동구매 관리 페이지로 이동

```dart
// 유통업자로 로그인 후
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DistributorGroupBuyingPage(
      distributorId: 'DIST001',  // 실제 유통업자 ID
      distributorName: '신선식품 유통',  // 실제 유통업자 이름
    ),
  ),
);
```

### 2. 공동구매 방 생성 흐름

1. **DistributorGroupBuyingPage**에서 "방 만들기" 버튼 클릭
2. **CreateGroupBuyingRoomPage**에서 정보 입력
3. "공동구매 방 만들기" 버튼 클릭
4. 방 생성 완료 → 목록으로 돌아감
5. 생성된 방은 "대기중" 상태

### 3. 방 오픈하기

1. 목록에서 "대기중" 상태의 방 찾기
2. "방 오픈하기" 버튼 클릭
3. 확인 다이얼로그에서 "오픈" 클릭
4. 방이 "오픈" 상태로 변경
5. 이제 가게들이 참여 가능

## 📋 방 생성 예제

### 예제 1: 김치 공동구매

```dart
// CreateGroupBuyingRoomPage에서 입력할 값들

방 제목: 🔥 김치 대박 세일! 20% 할인
상품 ID: 1
할인율: 20
준비한 재고: 500
목표 수량: 300
최소 주문: 10
최대 주문: 100
최소 참여자: 5
최대 참여자: 20
대상 지역: 서울 강남구,서초구
배송비: 50000
배송비 타입: 분담 배송비 (SHARED)
진행 시간: 24 (시간)
설명: 신선한 김치를 특가로 제공합니다!
특이사항: 당일 배송 보장
추천 방: 체크
```

### 예제 2: 과일 공동구매

```dart
방 제목: 🍎 사과 대량 할인! 30% OFF
상품 ID: 5
할인율: 30
준비한 재고: 1000
목표 수량: 800
최소 주문: 20
최대 주문: 200
최소 참여자: 10
최대 참여자: 50
대상 지역: 서울 전지역
배송비: 0
배송비 타입: 무료 배송 (FREE)
진행 시간: 48
설명: 신선한 사과를 대량으로 준비했습니다
특이사항: 냉장 배송
추천 방: 체크
```

## 🎯 방 상태 설명

| 상태 | 설명 | 가능한 액션 |
|------|------|------------|
| **대기중** (WAITING) | 방이 생성되었지만 아직 오픈 전 | 방 오픈하기, 취소 |
| **오픈** (OPEN) | 가게들이 참여 가능한 상태 | 수동 마감, 취소 |
| **마감성공** (CLOSED_SUCCESS) | 목표 달성하여 마감 | 주문 생성 |
| **마감실패** (CLOSED_FAILED) | 목표 미달로 마감 | - |
| **주문생성** (ORDER_CREATED) | 주문이 생성됨 | - |
| **완료** (COMPLETED) | 배송 완료 | - |
| **취소** (CANCELLED) | 방이 취소됨 | - |

## 🔄 방 생성 → 오픈 → 마감 흐름

```
1. 방 생성 (CreateGroupBuyingRoomPage)
   ↓
2. 대기중 상태 (WAITING)
   ↓
3. 방 오픈 (DistributorGroupBuyingPage에서 "방 오픈하기")
   ↓
4. 오픈 상태 (OPEN) - 가게들이 참여 시작
   ↓
5. 자동 마감 또는 수동 마감
   ↓
6. 마감성공 (CLOSED_SUCCESS) 또는 마감실패 (CLOSED_FAILED)
```

## 💡 팁

### 1. 배송비 타입 선택 가이드

- **무료 배송 (FREE)**: 배송비 0원, 프로모션용
- **고정 배송비 (FIXED)**: 각 가게가 동일한 배송비 부담
- **분담 배송비 (SHARED)**: 총 배송비를 참여자 수로 나눔 (추천!)

### 2. 목표 수량 설정

- 준비한 재고보다 적게 설정 권장
- 너무 높으면 달성 실패 가능성 증가
- 일반적으로 재고의 60-80% 정도로 설정

### 3. 진행 시간 설정

- 24시간: 빠른 회전율, 긴급 세일
- 48시간: 일반적인 공동구매
- 72시간 이상: 대량 상품, 여유있는 참여

### 4. 추천 방 설정

- 특별 프로모션이나 인기 상품에 사용
- 메인 페이지에 우선 노출
- 참여율 증가 효과

## 🔗 관련 API

### 방 생성
```
POST /api/group-buying/rooms
```

### 방 오픈
```
POST /api/group-buying/rooms/{roomId}/open?distributorId={distributorId}
```

### 내 방 목록 조회
```
GET /api/group-buying/rooms/distributor/{distributorId}
```

## 📊 Provider 사용 예제

```dart
// Provider 가져오기
final provider = context.read<DistributorGroupBuyingProvider>();

// 내 방 목록 조회
await provider.fetchMyRooms('DIST001');

// 방 생성
final success = await provider.createGroupBuyingRoom(
  roomTitle: '🔥 김치 대박 세일! 20% 할인',
  distributorId: 'DIST001',
  distributorName: '신선식품 유통',
  productId: 1,
  discountRate: 20.0,
  availableStock: 500,
  targetQuantity: 300,
  minOrderPerStore: 10,
  minParticipants: 5,
  region: '서울 강남구,서초구',
  deliveryFee: 50000,
  deliveryFeeType: 'SHARED',
  durationHours: 24,
  featured: true,
);

// 방 오픈
final opened = await provider.openGroupBuyingRoom(
  roomId: 'GBR-20231129143022-1234',
  distributorId: 'DIST001',
);
```

## 🎨 UI 특징

### DistributorGroupBuyingPage
- 카드 형태로 방 목록 표시
- 상태별 색상 구분 (대기중: 회색, 오픈: 초록색 등)
- 진행률 바 표시
- Pull to refresh 지원
- 빈 상태 UI (방이 없을 때)

### CreateGroupBuyingRoomPage
- 섹션별로 구분된 입력 폼
- 필수/선택 항목 구분
- 실시간 유효성 검사
- 드롭다운으로 배송비 타입 선택
- 스위치로 추천 방 설정

## 🚨 주의사항

1. **상품 ID는 실제 존재하는 상품이어야 합니다**
   - 카탈로그에 등록된 상품 ID 사용
   
2. **목표 수량은 재고보다 작거나 같아야 합니다**
   - 재고 초과 주문 방지

3. **방 오픈 후에는 취소만 가능합니다**
   - 오픈 전에 정보를 다시 확인하세요

4. **배송비 타입에 따라 가게별 배송비가 달라집니다**
   - SHARED: 참여자가 많을수록 배송비 감소

## 📱 실제 사용 시나리오

### 시나리오 1: 유통업자 로그인 후

```dart
// 1. 로그인 후 홈 화면에서
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistributorGroupBuyingPage(
          distributorId: currentUser.distributorId,
          distributorName: currentUser.name,
        ),
      ),
    );
  },
  child: Text('공동구매 관리'),
)

// 2. DistributorGroupBuyingPage에서 "방 만들기" 클릭
// 3. CreateGroupBuyingRoomPage에서 정보 입력
// 4. 방 생성 완료
// 5. 목록에서 "방 오픈하기" 클릭
// 6. 가게들이 참여 시작!
```

## 🎉 완료!

이제 유통업자는:
1. ✅ 공동구매 방을 생성할 수 있습니다
2. ✅ 생성한 방을 관리할 수 있습니다
3. ✅ 방을 오픈하여 가게들의 참여를 받을 수 있습니다
4. ✅ 실시간으로 진행 현황을 확인할 수 있습니다

가게는:
1. ✅ 오픈된 공동구매 방을 조회할 수 있습니다 (GroupBuyingListPage)
2. ✅ 방 상세 정보를 확인할 수 있습니다 (GroupBuyingDetailPage)
3. ✅ 공동구매에 참여할 수 있습니다
4. ✅ 내 참여 내역을 확인할 수 있습니다 (GroupBuyingMyParticipationsPage)
