# 주문 생성 400 에러 (빈 응답) 해결 가이드

## 증상

```
📥 응답 상태 코드: 400
📥 응답 본문: (비어있음)
❌ 에러 응답 파싱 실패: FormatException: Unexpected end of input
```

## 가능한 원인

### 1. 장바구니가 비어있음 ⭐ (가장 가능성 높음)

**상황:**
- 이전에 주문을 성공적으로 생성함
- 주문 성공 시 장바구니가 자동으로 비워짐
- 빈 장바구니로 다시 주문 시도

**확인 방법:**
```dart
print('🛒 장바구니 상태:');
print('  - 아이템 수: ${widget.cart.items.length}');
print('  - 총 금액: ${widget.cart.totalAmount}');
```

**해결:**
- 장바구니 페이지로 돌아가서 상품을 다시 추가
- 또는 주문 확인 페이지 진입 전에 장바구니 확인

### 2. 이미 해당 장바구니로 주문이 생성됨

**상황:**
- 서버가 중복 주문을 방지
- 같은 장바구니로 여러 번 주문 시도

**해결:**
- 새로운 장바구니 생성
- 서버에서 이전 주문 확인

### 3. 유효하지 않은 distributorId

**상황:**
- 장바구니의 distributorId가 서버에 존재하지 않음
- 또는 해당 유통업체가 비활성화됨

**확인:**
```
DistributorId: 김유통
```

**해결:**
- 유효한 유통업체의 카탈로그에서 상품 추가
- 서버 DB에서 distributorId 확인

### 4. 서버 측 유효성 검증 실패

**상황:**
- 서버가 빈 응답 본문으로 400 반환
- 로깅이 부족하거나 에러 핸들링이 누락됨

**해결:**
- 서버 로그 확인
- 서버 코드에 에러 메시지 추가

## 디버깅 단계

### 1. 장바구니 상태 확인

주문 확인 페이지에서:
```
🛒 장바구니 상태:
  - 아이템 수: 0  ← 비어있음!
  - 총 금액: 0
  - DistributorId: 김유통
```

만약 아이템 수가 0이면 → **장바구니가 비어있음**

### 2. 주문 플로우 확인

```
1. 카탈로그에서 상품 추가 → 장바구니에 아이템 있음
2. 장바구니에서 "주문하기" 클릭
3. 주문 확인 페이지로 이동
4. 배송 정보 입력 후 "주문하기"
5. 주문 성공 → 장바구니 자동 비우기 ✅
6. 뒤로가기 또는 다시 주문 시도 → 장바구니 비어있음 ❌
```

### 3. 서버 로그 확인

Spring Boot 서버에서:
```java
@PostMapping("/api/catalog-orders/create")
public ResponseEntity<?> createOrder(@RequestBody OrderCreateRequest request) {
    log.info("주문 생성 요청: {}", request);
    
    // 장바구니 조회
    Cart cart = cartService.getCart(storeId, request.getDistributorId());
    
    if (cart.getItems().isEmpty()) {
        log.warn("장바구니가 비어있음");
        return ResponseEntity.badRequest().build();  // ← 빈 응답!
    }
    
    // ...
}
```

## 해결 방법

### 클라이언트 측 (이미 적용됨)

1. **장바구니 확인 추가**
```dart
if (widget.cart.items.isEmpty) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('주문 불가'),
      content: const Text('장바구니가 비어있습니다.'),
    ),
  );
  return;
}
```

2. **에러 메시지 개선**
```dart
if (response.body.isEmpty) {
  errorMessage = '주문 생성 실패 (${response.statusCode}): 서버가 빈 응답을 반환했습니다.\n\n가능한 원인:\n- 장바구니가 비어있음\n- 이미 주문이 생성됨\n- 유효하지 않은 distributorId';
}
```

3. **상세 로깅**
```dart
print('🛒 장바구니 상태:');
print('  - 아이템 수: ${widget.cart.items.length}');
print('  - 총 금액: ${widget.cart.totalAmount}');
print('  - DistributorId: ${widget.cart.distributorId}');
```

### 서버 측 (권장)

1. **에러 응답에 메시지 포함**
```java
if (cart.getItems().isEmpty()) {
    return ResponseEntity.badRequest()
        .body(Map.of("message", "장바구니가 비어있습니다"));
}
```

2. **상세 로깅**
```java
log.info("장바구니 조회: storeId={}, distributorId={}, items={}", 
    storeId, distributorId, cart.getItems().size());
```

## 테스트 시나리오

### 정상 플로우
1. ✅ 카탈로그에서 상품 추가
2. ✅ 장바구니 확인 (아이템 있음)
3. ✅ 주문하기 클릭
4. ✅ 배송 정보 입력
5. ✅ 주문 생성 성공
6. ✅ 장바구니 비워짐

### 에러 플로우
1. ✅ 빈 장바구니로 주문 시도
2. ✅ "장바구니가 비어있습니다" 다이얼로그 표시
3. ✅ 카탈로그로 돌아가서 상품 추가

## 다음 단계

1. **장바구니 새로고침**
   - 주문 확인 페이지 진입 시 장바구니 최신 상태 확인
   
2. **주문 후 네비게이션 개선**
   - 주문 성공 후 장바구니 페이지로 돌아가지 않도록
   - 홈 또는 주문 내역으로 이동

3. **서버 에러 메시지 개선**
   - 모든 400 에러에 명확한 메시지 포함
   - 클라이언트가 적절히 대응할 수 있도록

## 현재 상태

✅ 클라이언트 측 개선 완료:
- 장바구니 확인 로직 추가
- 빈 응답 처리 개선
- 상세 로깅 추가

⏳ 서버 측 개선 필요:
- 에러 응답에 메시지 포함
- 장바구니 상태 로깅
