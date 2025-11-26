# 주문 생성 오류 디버깅 가이드

## 현재 상황

로그에서 확인된 내용:
```
StoreId: 김가게
distributorId: 김유통
```

**문제:** ID 필드에 한글 이름이 들어가고 있습니다.

## 원인 분석

### 1. UserModel.fromJson의 폴백 로직
```dart
// storeId가 없으면 username을 사용
String? storeId = json['storeId'] as String?;
if (storeId == null && userType == 'STORE_OWNER') {
  storeId = username;  // ❌ 이것이 문제!
}
```

### 2. 서버 응답 확인 필요
로그인 시 서버가 반환하는 실제 응답을 확인해야 합니다:
```
🔵 로그인 응답 본문: {...}
```

## 해결 방법

### 옵션 1: 서버가 올바른 ID를 반환하도록 수정 (권장)

서버의 로그인 API가 다음을 반환하도록 수정:
```json
{
  "userId": 1,
  "username": "김가게",
  "accessToken": "...",
  "tokenType": "Bearer",
  "userType": "STORE_OWNER",
  "businessName": "김가게",
  "storeId": "store-uuid-123",  // ✅ 실제 UUID나 숫자 ID
  "distributorId": null
}
```

### 옵션 2: 서버가 username을 ID로 사용하는 경우

만약 서버가 의도적으로 username을 ID로 사용한다면, 주문 생성 API도 username을 받도록 수정되어야 합니다.

## 다음 단계

1. **로그인 응답 확인**
   - 앱을 실행하고 로그인
   - 콘솔에서 `🔵 로그인 응답 본문` 확인
   - `storeId` 필드가 있는지, 값이 무엇인지 확인

2. **추가 디버그 정보 확인**
   주문 생성 시 다음 로그 확인:
   ```
   🔑 토큰 확인: ...
   🏪 StoreId: ...
   🏪 StoreId 타입: ...
   👤 Username: ...
   🏢 UserType: ...
   📦 주문 아이템 수: ...
   📦 DistributorId: ...
   ```

3. **서버 에러 메시지 확인**
   ```
   ❌ 서버 에러 메시지: ...
   ```

## 예상되는 서버 에러

### Case 1: ID 형식 오류
```
"Invalid UUID format for storeId"
"storeId must be a valid UUID"
```
→ 서버가 UUID를 기대하지만 한글 이름을 받음

### Case 2: 존재하지 않는 ID
```
"Store not found"
"Distributor not found"
```
→ 서버 DB에 해당 ID가 없음

### Case 3: 외래 키 제약 조건
```
"Foreign key constraint violation"
```
→ 잘못된 ID로 인한 DB 제약 조건 위반

## 임시 해결책 (테스트용)

만약 서버가 실제로 username을 ID로 사용한다면, `UserModel.fromJson`의 로직은 맞습니다. 
하지만 일반적으로는 **서버가 올바른 UUID나 숫자 ID를 반환**하도록 수정하는 것이 올바른 방법입니다.

## 체크리스트

- [ ] 로그인 응답에 `storeId` 필드가 있는가?
- [ ] `storeId` 값이 UUID 형식인가? (예: `550e8400-e29b-41d4-a716-446655440000`)
- [ ] 서버의 주문 생성 API가 어떤 형식의 ID를 기대하는가?
- [ ] 장바구니 조회 시 사용하는 `distributorId`는 어디서 오는가?
- [ ] 서버 에러 로그에 구체적인 오류 메시지가 있는가?
