# 주문 API 400 Bad Request 디버깅

## 현재 상황

서버 응답:
```json
{
  "timestamp": "2025-11-26T12:17:00.540+00:00",
  "status": 400,
  "error": "Bad Request",
  "path": "/api/catalog-orders/create"
}
```

전송한 데이터:
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

## 가능한 원인

### 1. 서버가 items를 기대하지 않음
원래 API 스펙 (ORDER_IMPLEMENTATION.md):
```json
{
  "distributorId": "string",
  "deliveryAddress": "string",
  "deliveryPhone": "string",
  "deliveryRequest": "string (optional)",
  "desiredDeliveryDate": "ISO8601 string (optional)"
}
```

→ **items 필드가 없음!** 서버가 장바구니에서 자동으로 가져올 수 있음

### 2. 날짜 형식 문제
- 현재: `2025-11-27T21:13:31.527667` (마이크로초 포함)
- 표준: `2025-11-27T21:13:31Z` (UTC)

### 3. storeId 필드
- 원래 스펙에는 헤더로 전달 (`X-Store-Id`)
- 현재는 body에 포함

### 4. 필수 필드 누락 또는 추가 필드
- 서버가 다른 필드를 기대할 수 있음

## 해결 시도

### 시도 1: items 제거 (서버가 장바구니에서 자동 가져오기)
```json
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31Z"
}
```

### 시도 2: storeId 제거 (토큰에서 추출)
```json
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111",
  "items": [{"productId": 4, "quantity": 1}],
  "deliveryRequest": "111",
  "desiredDeliveryDate": "2025-11-27T21:13:31Z"
}
```

### 시도 3: 최소 필드만 전송
```json
{
  "distributorId": "김유통",
  "deliveryAddress": "111111",
  "deliveryPhone": "01087661111"
}
```

## 서버 로그 확인 필요

서버 콘솔에서 다음을 확인:
1. 실제 받은 요청 데이터
2. 유효성 검증 실패 메시지
3. 스택 트레이스

일반적인 Spring Boot 에러:
- `@Valid` 검증 실패
- 필수 필드 누락
- 타입 불일치
- 외래 키 제약 조건

## 권장 사항

1. **서버 로그 확인** - 가장 정확한 원인 파악
2. **Postman/curl 테스트** - 서버 API 직접 테스트
3. **서버 API 문서 확인** - 정확한 스펙 확인
4. **다른 성공 케이스 비교** - 장바구니 API 등과 비교
