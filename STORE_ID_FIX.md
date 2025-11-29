# StoreId 에러 수정 완료

## 🐛 문제

가게 사장님으로 로그인해서 공동구매 참여 시 다음 에러 발생:
```
java.lang.IllegalArgumentException: 가게를 찾을 수 없습니다.
```

**원인**: 하드코딩된 `storeId` 값 `'STORE001'` 사용

## ✅ 수정 내용

### 1. group_buying_detail_page.dart
**Before:**
```dart
final success = await provider.joinGroupBuying(
  roomId: room.roomId,
  storeId: 'STORE001', // TODO: 실제 storeId로 교체
  quantity: quantity,
  ...
);
```

**After:**
```dart
final authProvider = context.read<AuthProvider>();
final storeId = authProvider.user?.storeId;

if (storeId == null) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('로그인 정보를 찾을 수 없습니다')),
  );
  return;
}

final success = await provider.joinGroupBuying(
  roomId: room.roomId,
  storeId: storeId, // 실제 로그인한 사용자의 storeId 사용
  quantity: quantity,
  ...
);
```

### 2. more_page.dart
**Before:**
```dart
GroupBuyingMyParticipationsPage(
  storeId: user?.storeId ?? 'STORE001', // fallback 사용
)
```

**After:**
```dart
onTap: () {
  if (user?.storeId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('가게 정보를 찾을 수 없습니다')),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GroupBuyingMyParticipationsPage(
        storeId: user!.storeId!, // null 체크 후 사용
      ),
    ),
  );
}
```

## 🔍 User 엔티티 구조

```dart
class User {
  final int userId;
  final String username;
  final String accessToken;
  final String tokenType;
  final String userType;
  final String businessName;
  final String? storeId;        // 가게 사장님인 경우
  final String? distributorId;  // 유통업자인 경우
  
  // ...
}
```

## 📋 체크리스트

- [x] 하드코딩된 `storeId` 제거
- [x] `AuthProvider`에서 실제 사용자 정보 가져오기
- [x] `storeId`가 null인 경우 에러 처리
- [x] 사용자 친화적인 에러 메시지 표시
- [x] `mounted` 체크로 메모리 누수 방지

## 🎯 테스트 시나리오

### 정상 케이스
1. 가게 사장님으로 로그인
2. 공동구매 목록에서 방 선택
3. 수량 입력 후 "참여하기" 클릭
4. ✅ 정상적으로 참여 완료

### 에러 케이스
1. 로그인 정보가 없는 경우
   - ❌ "로그인 정보를 찾을 수 없습니다" 메시지 표시
   
2. `storeId`가 없는 경우
   - ❌ "가게 정보를 찾을 수 없습니다" 메시지 표시

## 💡 추가 개선 사항

### 1. 로그인 체크 강화
공동구매 참여 전에 로그인 상태를 확인하고, 로그인되지 않은 경우 로그인 페이지로 이동:

```dart
if (authProvider.user == null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
  return;
}
```

### 2. 가게 등록 유도
`storeId`가 없는 경우 (회원가입만 하고 가게 등록을 안 한 경우) 가게 등록 페이지로 이동:

```dart
if (storeId == null) {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('가게 등록 필요'),
      content: const Text('공동구매에 참여하려면 가게 등록이 필요합니다.\n가게 등록 페이지로 이동하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('등록하기'),
        ),
      ],
    ),
  );
  
  if (confirm == true && mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoreRegistrationPage()),
    );
  }
  return;
}
```

### 3. 유통업자 접근 차단
유통업자가 가게 전용 기능에 접근하지 못하도록:

```dart
if (authProvider.user?.userType != 'STORE_OWNER') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('가게 사장님만 이용 가능한 기능입니다')),
  );
  return;
}
```

## 🔐 보안 고려사항

1. **서버 측 검증**: 클라이언트에서 `storeId`를 보내더라도 서버에서 JWT 토큰의 사용자 정보와 일치하는지 검증 필요

2. **권한 체크**: 다른 가게의 `storeId`로 요청하는 것을 방지

3. **세션 만료**: 토큰이 만료된 경우 자동 로그아웃 및 재로그인 유도

## 🎉 결과

이제 가게 사장님이 공동구매에 참여할 때:
- ✅ 실제 로그인한 사용자의 `storeId` 사용
- ✅ 서버에서 해당 가게를 정상적으로 찾을 수 있음
- ✅ "가게를 찾을 수 없습니다" 에러 해결
- ✅ 정상적으로 공동구매 참여 가능

## 📝 참고

- User 엔티티: `lib/domain/entities/user.dart`
- AuthProvider: `lib/presentation/providers/auth_provider.dart`
- 수정된 파일:
  - `lib/presentation/pages/group_buying_detail_page.dart`
  - `lib/presentation/pages/more_page.dart`
