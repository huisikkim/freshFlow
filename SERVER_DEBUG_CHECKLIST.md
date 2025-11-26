# 서버 측 디버깅 체크리스트

## 주문 생성 API 400 Bad Request 해결

### 1. 서버 로그 확인

Spring Boot 애플리케이션에서 다음을 확인하세요:

```bash
# 서버 콘솔에서 에러 로그 찾기
# 일반적으로 다음과 같은 형식:
```

**찾아야 할 정보:**
- `@Valid` 검증 실패 메시지
- `MethodArgumentNotValidException`
- `ConstraintViolationException`
- 필드별 에러 메시지

### 2. Controller 확인

```java
@PostMapping("/api/catalog-orders/create")
public ResponseEntity<?> createOrder(
    @RequestBody @Valid OrderCreateRequest request,
    @AuthenticationPrincipal UserDetails userDetails
) {
    // ...
}
```

**확인 사항:**
- `OrderCreateRequest` DTO의 필드 정의
- `@Valid` 어노테이션 사용 여부
- 필수 필드 (`@NotNull`, `@NotBlank` 등)
- 토큰에서 storeId 추출 방식

### 3. DTO 확인

```java
public class OrderCreateRequest {
    @NotBlank
    private String distributorId;
    
    @NotBlank
    private String deliveryAddress;
    
    @NotBlank
    private String deliveryPhone;
    
    private String deliveryRequest;  // Optional
    
    private LocalDateTime desiredDeliveryDate;  // Optional
    
    // items 필드가 있는지?
    private List<OrderItemRequest> items;  // 있다면 필수인지?
    
    // storeId 필드가 있는지?
    private String storeId;  // 있다면 필수인지?
}
```

### 4. 가능한 문제들

#### A. items 필드 관련
```
❌ 서버가 items를 필수로 요구하는데 클라이언트가 보내지 않음
✅ 해결: items 포함해서 전송

❌ 서버가 items를 받지 않는데 클라이언트가 보냄
✅ 해결: items 제거

❌ items 형식이 다름 (예: productId vs product_id)
✅ 해결: 필드명 확인
```

#### B. storeId 관련
```
❌ 서버가 body에서 storeId를 필수로 요구
✅ 해결: body에 storeId 포함

❌ 서버가 토큰에서 storeId를 추출하는데 클라이언트가 body에 포함
✅ 해결: body에서 storeId 제거

❌ storeId 타입 불일치 (String vs Long)
✅ 해결: 타입 확인
```

#### C. distributorId 관련
```
❌ distributorId가 DB에 존재하지 않음
✅ 해결: 유효한 distributorId 사용

❌ distributorId 타입 불일치
✅ 해결: 타입 확인 (String vs Long vs UUID)
```

#### D. 날짜 형식
```
❌ 서버가 다른 날짜 형식을 기대
✅ 해결: ISO 8601 형식 사용 (2025-11-27T21:13:31Z)

❌ 타임존 문제
✅ 해결: UTC 사용
```

### 5. 테스트 방법

#### Postman으로 직접 테스트

```bash
POST http://localhost:8080/api/catalog-orders/create
Headers:
  Authorization: Bearer {실제_토큰}
  Content-Type: application/json

Body (시도 1 - items 포함):
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "items": [{"productId": 4, "quantity": 1}],
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31Z"
}

Body (시도 2 - items 제외):
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31Z"
}

Body (시도 3 - 최소 필드):
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111"
}
```

### 6. 서버 로깅 추가

Controller에 로깅 추가:

```java
@PostMapping("/api/catalog-orders/create")
public ResponseEntity<?> createOrder(
    @RequestBody @Valid OrderCreateRequest request,
    @AuthenticationPrincipal UserDetails userDetails
) {
    log.info("📥 주문 생성 요청 받음");
    log.info("User: {}", userDetails.getUsername());
    log.info("Request: {}", request);
    log.info("DistributorId: {}", request.getDistributorId());
    log.info("Items: {}", request.getItems());
    
    try {
        // 주문 생성 로직
    } catch (Exception e) {
        log.error("❌ 주문 생성 실패", e);
        throw e;
    }
}
```

### 7. 일반적인 Spring Boot 400 에러

```java
// 1. Validation 실패
@NotBlank(message = "배송 주소는 필수입니다")
private String deliveryAddress;

// 2. 타입 변환 실패
private Long productId;  // 서버
vs
"productId": "4"  // 클라이언트 (String)

// 3. 날짜 파싱 실패
@JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss'Z'")
private LocalDateTime desiredDeliveryDate;

// 4. 필수 필드 누락
@NotNull
private List<OrderItemRequest> items;
```

### 8. 해결 순서

1. ✅ 서버 콘솔에서 정확한 에러 메시지 확인
2. ✅ Controller와 DTO 코드 확인
3. ✅ Postman으로 직접 테스트
4. ✅ 필드명, 타입, 필수 여부 확인
5. ✅ 클라이언트 코드 수정

### 9. 현재 클라이언트 상태

**전송 중인 데이터 (items 제외):**
```json
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31Z"
}
```

**다음 시도:**
만약 위 방식도 실패하면, 서버 로그의 정확한 에러 메시지를 확인해주세요.
