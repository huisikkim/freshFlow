# HTTP 헤더 한글 문제 해결

## 발견된 오류

```
FormatException: Invalid HTTP header field value: "김가게" (at character 1)
김가게
^
```

## 원인

HTTP 헤더는 **ASCII 문자만 허용**합니다. 한글이나 다른 유니코드 문자를 헤더 값으로 사용할 수 없습니다.

기존 코드:
```dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
  'X-Store-Id': storeId,  // ❌ storeId = "김가게" (한글)
}
```

## 해결 방법

### 1. 주문 생성 API
헤더 대신 **요청 body에 storeId 포함**:

```dart
final body = {
  'storeId': storeId,  // ✅ body에 포함
  'distributorId': distributorId,
  'deliveryAddress': deliveryAddress,
  'deliveryPhone': deliveryPhone,
  'items': items,
  // ...
};

headers: {
  'Content-Type': 'application/json; charset=utf-8',
  'Authorization': 'Bearer $token',
  // X-Store-Id 헤더 제거
}
```

### 2. 주문 조회 API
**쿼리 파라미터로 storeId 전달**:

```dart
// GET /api/catalog-orders?storeId=김가게
final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders')
    .replace(queryParameters: {'storeId': storeId});

final response = await client.get(
  uri,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
);
```

### 3. 주문 상세 조회 API
```dart
// GET /api/catalog-orders/{orderId}?storeId=김가게
final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/$orderId')
    .replace(queryParameters: {'storeId': storeId});
```

### 4. 주문 취소 API
```dart
// POST /api/catalog-orders/{orderId}/cancel?storeId=김가게
final uri = Uri.parse('${ApiConstants.baseUrl}/api/catalog-orders/$orderId/cancel')
    .replace(queryParameters: {'storeId': storeId});
```

## 수정된 파일

- `lib/data/datasources/order_remote_data_source.dart`
  - `createOrder`: body에 storeId 추가, X-Store-Id 헤더 제거
  - `getOrders`: 쿼리 파라미터로 storeId 전달
  - `getOrderById`: 쿼리 파라미터로 storeId 전달
  - `cancelOrder`: 쿼리 파라미터로 storeId 전달

## 왜 이런 문제가 발생했나?

1. **서버가 storeId를 제대로 반환하지 않음**
   - 로그인 응답에 `storeId` 필드가 없음
   - `UserModel`이 폴백으로 `username`(한글)을 사용

2. **HTTP 헤더에 한글 사용 시도**
   - HTTP 헤더는 ASCII만 허용
   - 한글을 헤더에 넣으면 `FormatException` 발생

## 근본적인 해결책

서버의 로그인 API가 올바른 `storeId`를 반환하도록 수정:

```json
{
  "userId": 1,
  "username": "김가게",
  "accessToken": "...",
  "tokenType": "Bearer",
  "userType": "STORE_OWNER",
  "businessName": "김가게",
  "storeId": "store-uuid-123",  // ✅ UUID나 숫자 ID
  "distributorId": null
}
```

하지만 현재는 서버가 username을 ID로 사용하는 것으로 보이므로, 클라이언트에서 한글 ID를 안전하게 전달할 수 있도록 수정했습니다.

## URL 인코딩

쿼리 파라미터는 자동으로 URL 인코딩됩니다:
- `김가게` → `%EA%B9%80%EA%B0%80%EA%B2%8C`
- 서버에서 자동으로 디코딩됨

## 테스트

주문 생성 시 다음과 같이 전송됩니다:

**URL:**
```
POST http://localhost:8080/api/catalog-orders/create
```

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9...
Content-Type: application/json; charset=utf-8
```

**Body:**
```json
{
  "storeId": "김가게",
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "items": [{"productId": 4, "quantity": 1}],
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31.527667"
}
```

이제 한글 ID가 안전하게 전달됩니다! ✅
