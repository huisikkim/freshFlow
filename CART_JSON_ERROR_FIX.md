# 장바구니 JSON 파싱 오류 해결

## 문제 상황

장바구니 목록을 열 때 다음과 같은 오류 발생:
```
FormatException: Unexpected character (at character 23365)
..."김가게", "distributorId":"김유통","items":]}}]
```

오류 원인: 서버에서 반환하는 JSON에 `]}}]` 같은 잘못된 괄호 중복이 있음

## 해결 방법

### 1. 클라이언트 측 임시 해결 (완료)

`lib/data/datasources/cart_remote_datasource.dart`에 JSON 정리 로직 추가:

```dart
String _cleanJsonResponse(String response) {
  String cleaned = response;
  
  // 중복된 닫는 괄호 제거
  cleaned = cleaned.replaceAll(RegExp(r'\]\}\}\]'), ']}');
  cleaned = cleaned.replaceAll(RegExp(r'\]\}\]'), ']}');
  
  return cleaned;
}
```

이제 앱은:
1. 먼저 원본 JSON 파싱 시도
2. 실패하면 JSON 정리 후 재시도
3. 여전히 실패하면 상세한 오류 메시지와 함께 콘솔에 응답 내용 출력

### 2. 서버 측 근본 해결 (권장)

서버에서 올바른 JSON 형식을 반환하도록 수정해야 합니다.

#### 올바른 JSON 형식:
```json
{
  "id": 1,
  "storeId": "김가게",
  "distributorId": "김유통",
  "items": [
    {
      "id": 1,
      "productId": 123,
      "productName": "상품명",
      "unitPrice": 10000,
      "unit": "kg",
      "quantity": 5,
      "subtotal": 50000,
      "imageUrl": "https://..."
    }
  ],
  "totalAmount": 50000,
  "totalQuantity": 5
}
```

#### 잘못된 형식 (현재 서버 응답):
```json
{
  "id": 1,
  "storeId": "김가게",
  "distributorId": "김유통",
  "items": []}}]  ← 이 부분이 잘못됨
```

## 디버깅 방법

### 1. 콘솔 로그 확인

앱을 실행하고 장바구니를 열면 콘솔에 다음 정보가 출력됩니다:

```
JSON 파싱 오류: FormatException: ...
원본 응답 (처음 1000자): {...}
원본 응답 (마지막 200자): {...}
정리된 응답 시도 중...
```

### 2. 서버 API 직접 테스트

```bash
# 장바구니 조회 API 테스트
curl -X GET "http://your-server/api/cart/distributorId" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  | jq .
```

`jq` 명령어가 JSON 파싱 오류를 표시하면 서버 측 문제입니다.

### 3. 서버 로그 확인

서버 측에서 Cart 객체를 JSON으로 직렬화하는 부분을 확인:
- Jackson (Java/Spring)
- Gson (Java)
- JSON.stringify (Node.js)
- json.dumps (Python)

## 서버 측 수정 예시

### Spring Boot (Java)
```java
@GetMapping("/api/cart/{distributorId}")
public ResponseEntity<Cart> getCart(@PathVariable String distributorId) {
    Cart cart = cartService.getCart(distributorId);
    
    // 디버깅: JSON 직렬화 확인
    ObjectMapper mapper = new ObjectMapper();
    try {
        String json = mapper.writeValueAsString(cart);
        System.out.println("Cart JSON: " + json);
    } catch (JsonProcessingException e) {
        e.printStackTrace();
    }
    
    return ResponseEntity.ok(cart);
}
```

### 일반적인 원인

1. **중복 직렬화**: 객체가 두 번 직렬화되는 경우
2. **순환 참조**: 객체 간 순환 참조로 인한 무한 루프
3. **커스텀 Serializer 오류**: 잘못 구현된 JSON 직렬화 로직
4. **문자열 연결**: JSON을 문자열로 직접 조합하는 경우

## 테스트 방법

### 1. 정상 케이스
```dart
// 빈 장바구니
{
  "id": 1,
  "storeId": "store1",
  "distributorId": "dist1",
  "items": [],
  "totalAmount": 0,
  "totalQuantity": 0
}
```

### 2. 상품이 있는 케이스
```dart
// 상품 1개
{
  "id": 1,
  "storeId": "store1",
  "distributorId": "dist1",
  "items": [
    {
      "id": 1,
      "productId": 100,
      "productName": "사과",
      "unitPrice": 5000,
      "unit": "kg",
      "quantity": 2,
      "subtotal": 10000,
      "imageUrl": null
    }
  ],
  "totalAmount": 10000,
  "totalQuantity": 2
}
```

### 3. 여러 상품 케이스
```dart
// 상품 여러 개
{
  "id": 1,
  "storeId": "store1",
  "distributorId": "dist1",
  "items": [
    {...},
    {...},
    {...}
  ],
  "totalAmount": 50000,
  "totalQuantity": 10
}
```

## 현재 상태

✅ 클라이언트에서 잘못된 JSON 정리 시도
✅ 상세한 에러 로그 출력
✅ 사용자에게 명확한 오류 메시지 표시

⚠️ 서버 측 JSON 형식 수정 필요 (근본 해결)

## 다음 단계

1. 앱 실행 후 콘솔 로그 확인
2. 서버 응답의 정확한 형식 파악
3. 서버 측 JSON 직렬화 로직 수정
4. 수정 후 클라이언트의 임시 정리 로직 제거 가능

## 추가 정보

문제가 계속되면 다음 정보를 제공해주세요:
- 콘솔에 출력된 전체 JSON 응답
- 서버 프레임워크 및 버전
- Cart 엔티티/모델 클래스 코드
