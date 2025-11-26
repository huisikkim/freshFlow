# 주문 생성 기능 구현 완료

## ✅ 구현된 내용

### 1. Domain Layer (비즈니스 로직)

#### Order Entity (`lib/domain/entities/order.dart`)
- 주문 정보를 담는 엔티티
- 주문 상태 (OrderStatus enum): PENDING, CONFIRMED, PREPARING, SHIPPED, DELIVERED, CANCELLED
- 주문 취소 가능 여부 체크 (`canCancel` getter)

#### Order Repository Interface (`lib/domain/repositories/order_repository.dart`)
- `createOrder()`: 주문 생성
- `getOrders()`: 주문 목록 조회
- `getOrderById()`: 특정 주문 조회
- `cancelOrder()`: 주문 취소

#### Use Cases (`lib/domain/usecases/order_usecases.dart`)
- `CreateOrderUseCase`: 주문 생성
- `GetOrdersUseCase`: 주문 목록 조회
- `GetOrderByIdUseCase`: 특정 주문 조회
- `CancelOrderUseCase`: 주문 취소

### 2. Data Layer (데이터 처리)

#### Order Model (`lib/data/models/order_model.dart`)
- JSON 직렬화/역직렬화
- Entity와 Model 변환

#### Order Remote Data Source (`lib/data/datasources/order_remote_data_source.dart`)
- API 엔드포인트: `POST /catalog-orders/create`
- 헤더: `Authorization: Bearer {token}`, `X-Store-Id: {storeId}`
- 요청 Body:
  ```json
  {
    "distributorId": "string",
    "deliveryAddress": "string",
    "deliveryPhone": "string",
    "deliveryRequest": "string (optional)",
    "desiredDeliveryDate": "ISO8601 string (optional)"
  }
  ```

#### Order Repository Implementation (`lib/data/repositories/order_repository_impl.dart`)
- Either 패턴을 사용한 에러 핸들링
- Exception을 Failure로 변환

### 3. Presentation Layer (UI)

#### Order Provider (`lib/presentation/providers/order_provider.dart`)
- 주문 상태 관리 (OrderState: initial, loading, loaded, error)
- 주문 생성, 조회, 취소 기능

#### Order Confirmation Page 업데이트 (`lib/presentation/pages/order_confirmation_page.dart`)
- 배송 정보 입력 폼 (주소, 연락처, 희망 배송일, 요청사항)
- 실제 주문 API 호출 연동
- 주문 성공 시 장바구니 자동 비우기
- 로딩 및 에러 처리

### 4. 의존성 주입 (`lib/injection_container.dart`)
- OrderRemoteDataSource 등록
- OrderRepository 등록
- Order UseCases 등록
- OrderProvider 등록

### 5. 에러 처리 (`lib/core/errors/`)
- `exceptions.dart`: ServerException, UnauthorizedException, NotFoundException
- `failures.dart`: ServerFailure, UnauthorizedFailure, NotFoundFailure

## 📋 주문 생성 플로우

```
1. 사용자가 장바구니에서 "주문하기" 클릭
   ↓
2. OrderConfirmationPage로 이동
   ↓
3. 배송 정보 입력 (주소, 연락처, 희망 배송일, 요청사항)
   ↓
4. "주문하기" 버튼 클릭
   ↓
5. OrderProvider.createOrder() 호출
   ↓
6. CreateOrderUseCase 실행
   ↓
7. OrderRepository를 통해 API 호출
   ↓
8. 주문 성공 시:
   - 장바구니 비우기
   - 성공 다이얼로그 표시
   - 홈으로 이동
   
   주문 실패 시:
   - 에러 다이얼로그 표시
```

## 🔧 사용 방법

### 주문 생성
```dart
final orderProvider = context.read<OrderProvider>();

final success = await orderProvider.createOrder(
  distributorId: 'distributor123',
  deliveryAddress: '서울시 강남구 테헤란로 123',
  deliveryPhone: '010-1234-5678',
  deliveryRequest: '문 앞에 놓아주세요',
  desiredDeliveryDate: DateTime.now().add(Duration(days: 1)),
);

if (success) {
  // 주문 성공
  final order = orderProvider.currentOrder;
} else {
  // 주문 실패
  final error = orderProvider.errorMessage;
}
```

## 📦 의존성

- `dartz: ^0.10.1` - Either 패턴을 위한 함수형 프로그래밍 라이브러리
- `http: ^1.2.0` - HTTP 요청
- `shared_preferences: ^2.2.2` - 로컬 저장소 (토큰, storeId)
- `provider: ^6.1.1` - 상태 관리

## 🎯 다음 단계

- [ ] 주문 내역 조회 페이지 구현
- [ ] 주문 상세 페이지 구현
- [ ] 주문 취소 기능 UI 구현
- [ ] 주문 상태 변경 알림
- [ ] 재주문 기능

## 🔑 주요 특징

1. **Clean Architecture**: Domain, Data, Presentation 레이어 분리
2. **에러 핸들링**: Either 패턴을 사용한 안전한 에러 처리
3. **상태 관리**: Provider를 사용한 반응형 UI
4. **타입 안전성**: 강타입 언어의 장점 활용
5. **확장 가능성**: 새로운 기능 추가가 용이한 구조
