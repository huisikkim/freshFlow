# 토스페이먼츠 간편결제 통합 완료

## 구현 내용

### 1. 결제 흐름
```
장바구니 → 주문 확인 → 주문 생성 → 토스페이 결제 → 결제 승인 → 완료
```

### 2. 추가된 파일
- `lib/presentation/pages/toss_payment_page.dart` - 토스페이 WebView 결제 페이지
- `lib/domain/usecases/order_usecases.dart` - ConfirmPaymentUseCase 추가

### 3. 수정된 파일
- `pubspec.yaml` - webview_flutter 패키지 추가
- `lib/core/constants/api_constants.dart` - 결제 승인 엔드포인트 추가
- `lib/data/datasources/order_remote_data_source.dart` - confirmPayment 메서드 추가
- `lib/domain/repositories/order_repository.dart` - confirmPayment 추가
- `lib/data/repositories/order_repository_impl.dart` - confirmPayment 구현
- `lib/presentation/providers/order_provider.dart` - confirmPayment 메서드 추가
- `lib/presentation/pages/order_confirmation_page.dart` - 결제 흐름 통합
- `lib/injection_container.dart` - ConfirmPaymentUseCase 등록

## 사용 방법

### 1. 토스페이먼츠 클라이언트 키 설정
`lib/presentation/pages/toss_payment_page.dart` 파일의 48번째 줄:
```dart
const clientKey = 'test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq'; // 실제 키로 교체
```

**테스트 환경**: `test_ck_` 로 시작하는 키 사용
**운영 환경**: `live_ck_` 로 시작하는 키 사용

### 2. 결제 흐름

#### 2-1. 주문 생성
사용자가 "주문하기" 버튼을 누르면:
- 배송 정보 입력 확인
- 주문 생성 API 호출 (`POST /api/catalog-orders/create`)
- 주문 ID 받기

#### 2-2. 토스페이 결제
주문 생성 성공 후:
- `TossPaymentPage`로 이동
- WebView에서 토스페이먼츠 결제 UI 표시
- 사용자가 결제 진행

#### 2-3. 결제 결과 처리
- **성공**: `https://your-app.com/payment/success?paymentKey=xxx&orderId=xxx&amount=xxx`
- **실패**: `https://your-app.com/payment/fail?code=xxx&message=xxx`

#### 2-4. 결제 승인
결제 성공 시:
- 결제 승인 API 호출 (`POST /api/orders/{orderId}/payment/confirm`)
- Body: `{ "paymentKey": "xxx", "orderId": "xxx", "amount": 123 }`

#### 2-5. 완료
- 장바구니 비우기
- 성공 다이얼로그 표시
- 홈으로 이동

## 백엔드 API 요구사항

### 1. 주문 생성 API
```
POST /api/catalog-orders/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "distributorId": "dist-123",
  "deliveryAddress": "서울시 강남구...",
  "deliveryPhone": "010-1234-5678",
  "deliveryRequest": "문 앞에 놔주세요",
  "desiredDeliveryDate": "2025-11-28T00:00:00Z"
}

Response: 201 Created
{
  "id": "1",
  "status": "PENDING",
  ...
}
```

### 2. 결제 승인 API
```
POST /api/orders/{orderId}/payment/confirm
Authorization: Bearer {token}
Content-Type: application/json

{
  "paymentKey": "tgen_20231126143025_abc123",
  "orderId": "ORDER-1",
  "amount": 480000
}

Response: 200 OK
{
  "id": "1",
  "status": "PAID",
  "paymentKey": "tgen_20231126143025_abc123",
  ...
}
```

## 테스트 방법

### 1. 테스트 카드 정보 (토스페이먼츠 제공)
- 카드번호: 5570-1234-5678-9012
- 유효기간: 12/25
- CVC: 123
- 비밀번호 앞 2자리: 12

### 2. 테스트 시나리오
1. 가게사장님으로 로그인
2. 유통업체 카탈로그에서 상품 장바구니 담기
3. 장바구니에서 "주문하기" 클릭
4. 배송 정보 입력
5. "결제하기" 버튼 클릭
6. 토스페이 결제 화면에서 테스트 카드로 결제
7. 결제 성공 확인
8. 주문 목록에서 주문 상태 확인

## 주의사항

### 1. 클라이언트 키 관리
- 테스트/운영 환경에 따라 다른 키 사용
- 환경 변수나 설정 파일로 관리 권장

### 2. 콜백 URL
현재 `https://your-app.com/payment/success` 사용 중
- 실제 도메인으로 변경 필요 없음 (WebView에서 URL 패턴만 감지)
- 토스페이먼츠 대시보드에 등록 불필요

### 3. 에러 처리
- 결제 실패 시 주문은 생성되었으나 결제 미완료 상태
- 필요시 주문 취소 로직 추가 고려

### 4. 보안
- 결제 승인은 반드시 서버에서 검증
- 클라이언트에서 받은 paymentKey, amount를 서버에서 재확인

## 다음 단계

1. **토스페이먼츠 계정 설정**
   - https://developers.tosspayments.com/ 에서 계정 생성
   - 클라이언트 키 발급
   - 테스트 환경에서 충분히 테스트 후 운영 키 발급

2. **환경별 키 관리**
   - 개발/운영 환경 분리
   - 환경 변수로 키 관리

3. **추가 기능**
   - 결제 취소/환불 기능
   - 결제 내역 조회
   - 영수증 발행
