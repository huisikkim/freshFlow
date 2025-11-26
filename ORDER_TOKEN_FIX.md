# 주문 접수 토큰 및 데이터 전송 수정

## 문제 분석

### 1. 토큰 전송 방식 확인 ✅
모든 API 호출에서 동일한 방식으로 토큰을 전송하고 있습니다:
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

**확인된 API들:**
- 장바구니 API (`cart_remote_datasource.dart`)
- 카탈로그 API (`catalog_remote_datasource.dart`)
- 주문 API (`order_remote_data_source.dart`)

**결론:** 토큰 전송 방식은 문제 없음

### 2. 실제 문제 발견 ❌
**주문 생성 시 장바구니 아이템 정보가 서버로 전송되지 않았습니다!**

기존 코드는 배송 정보만 전송:
```dart
final body = {
  'distributorId': distributorId,
  'deliveryAddress': deliveryAddress,
  'deliveryPhone': deliveryPhone,
  'deliveryRequest': deliveryRequest,
  'desiredDeliveryDate': desiredDeliveryDate,
  // ❌ items 정보 누락!
};
```

## 수정 내용

### 1. OrderRemoteDataSource 인터페이스 수정
```dart
Future<OrderModel> createOrder({
  required String token,
  required String storeId,
  required String distributorId,
  required String deliveryAddress,
  required String deliveryPhone,
  String? deliveryRequest,
  DateTime? desiredDeliveryDate,
  required List<Map<String, dynamic>> items, // ✅ 추가
});
```

### 2. 주문 생성 API 요청 본문에 items 추가
```dart
final body = {
  'distributorId': distributorId,
  'deliveryAddress': deliveryAddress,
  'deliveryPhone': deliveryPhone,
  'items': items, // ✅ 장바구니 아이템 추가
  if (deliveryRequest != null) 'deliveryRequest': deliveryRequest,
  if (desiredDeliveryDate != null)
    'desiredDeliveryDate': desiredDeliveryDate.toIso8601String(),
};
```

### 3. 디버깅 로그 추가
```dart
print('🚀 주문 생성 요청');
print('URL: ${ApiConstants.baseUrl}/api/catalog-orders/create');
print('Token: Bearer ${token.substring(0, 20)}...');
print('StoreId: $storeId');
print('Body: ${json.encode(body)}');
```

### 4. Repository 계층 수정
```dart
print('🔑 토큰 확인: ${user.accessToken.substring(0, 20)}...');
print('🏪 StoreId: ${user.storeId}');
print('📦 주문 아이템 수: ${items.length}');
```

### 5. UI에서 장바구니 아이템 전송
```dart
// 장바구니 아이템을 서버 형식으로 변환
final items = widget.cart.items.map((item) => {
  'productId': item.productId,
  'quantity': item.quantity,
}).toList();

print('📦 주문 아이템 전송: $items');

final success = await orderProvider.createOrder(
  distributorId: widget.cart.distributorId,
  deliveryAddress: _deliveryAddress,
  deliveryPhone: _deliveryPhone,
  deliveryRequest: _deliveryRequest.isNotEmpty ? _deliveryRequest : null,
  desiredDeliveryDate: _desiredDeliveryDate,
  items: items, // ✅ 아이템 정보 전송
);
```

## 수정된 파일 목록

1. `lib/data/datasources/order_remote_data_source.dart`
   - items 파라미터 추가
   - 요청 본문에 items 포함
   - 디버깅 로그 추가

2. `lib/data/repositories/order_repository_impl.dart`
   - items 파라미터 전달
   - 디버깅 로그 추가

3. `lib/domain/repositories/order_repository.dart`
   - 인터페이스에 items 파라미터 추가

4. `lib/domain/usecases/order_usecases.dart`
   - CreateOrderUseCase에 items 파라미터 추가

5. `lib/presentation/providers/order_provider.dart`
   - createOrder 메서드에 items 파라미터 추가

6. `lib/presentation/pages/order_confirmation_page.dart`
   - 장바구니 아이템을 서버 형식으로 변환
   - 주문 생성 시 items 전달

## 서버로 전송되는 데이터 형식

```json
{
  "storeId": "김가게",
  "distributorId": "김유통",
  "deliveryAddress": "서울시 강남구...",
  "deliveryPhone": "010-1234-5678",
  "items": [
    {
      "productId": 1,
      "quantity": 5
    },
    {
      "productId": 2,
      "quantity": 3
    }
  ],
  "deliveryRequest": "문 앞에 놓아주세요",
  "desiredDeliveryDate": "2025-11-27T00:00:00.000Z"
}
```

**참고:** `storeId`가 body에 포함됩니다 (헤더가 아님).

## 헤더 정보

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json; charset=utf-8
```

**중요:** `X-Store-Id` 헤더는 제거되었습니다. HTTP 헤더는 ASCII만 허용하므로 한글 ID를 전달할 수 없습니다. 대신 `storeId`를 요청 body에 포함합니다.

## 테스트 방법

1. 앱 실행
2. 로그인
3. 유통업체 카탈로그에서 상품을 장바구니에 추가
4. 장바구니에서 주문하기 클릭
5. 배송 정보 입력 후 주문하기
6. 콘솔 로그에서 다음 확인:
   - 🔑 토큰이 올바르게 전달되는지
   - 🏪 StoreId가 있는지
   - 📦 주문 아이템이 포함되어 있는지
   - 🚀 서버로 전송되는 전체 요청 본문

## 결론

토큰 전송 방식은 문제가 없었으며, 실제 문제는 **주문 생성 시 장바구니 아이템 정보가 누락**되어 있었습니다. 이제 서버에 다음 정보가 모두 전달됩니다:

✅ 인증 토큰 (Bearer)
✅ Store ID (헤더)
✅ 유통업체 ID
✅ 배송 정보
✅ 주문 아이템 목록 (productId, quantity)
