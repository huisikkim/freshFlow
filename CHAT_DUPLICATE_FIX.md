# 🔧 유통업자 채팅 중복 메시지 문제 해결

## ❌ 발생한 문제

**증상:**
1. 유통업자로 로그인하여 채팅하면 메시지가 중복으로 표시됨
2. 채팅방 이름이 잘못 표시됨 (항상 유통업체 이름만 표시)
3. 모든 메시지가 상대방 메시지로 표시됨 (내 메시지가 왼쪽에 표시)

## 🔍 원인 분석

### 1. 메시지 중복 표시
**원인:**
- `enterRoom`에서 WebSocket 구독 시 중복 구독 확인 없음
- 같은 채팅방에 여러 번 구독하면 메시지가 여러 번 수신됨
- 이전 채팅방 구독 해제 없이 새 채팅방 구독

### 2. 잘못된 표시 이름
**원인:**
```dart
// 항상 distributorName만 표시
final displayName = widget.room.distributorName;
```
- userType 확인 없이 항상 `distributorName` 사용
- 유통업자가 보면 자기 이름이 표시되어야 하는데 상대방 이름 표시

### 3. 메시지 방향 문제
**원인:**
```dart
// 항상 false로 설정
final isMe = false;
```
- 현재 사용자 ID 확인 없이 항상 `false`
- 모든 메시지가 상대방 메시지로 표시

## ✅ 해결 방법

### 1. 중복 구독 방지

**수정 파일:** `lib/presentation/providers/chat_provider.dart`

**추가된 상태 변수:**
```dart
String? _subscribedRoomId; // 현재 구독 중인 채팅방 ID
```

**수정된 enterRoom 메서드:**
```dart
Future<void> enterRoom(String roomId, String accessToken) async {
  // 이미 같은 채팅방을 구독 중이면 리턴
  if (_subscribedRoomId == roomId) {
    return;
  }

  // 이전 채팅방 구독 해제
  if (_subscribedRoomId != null && _isConnected) {
    webSocketRepository.unsubscribe(_subscribedRoomId!);
  }

  // WebSocket이 연결되지 않았으면 연결 시도
  if (!_isConnected) {
    try {
      await connectWebSocket(accessToken);
    } catch (e) {
      _error = 'WebSocket 연결 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  if (_isConnected) {
    // WebSocket 구독
    try {
      webSocketRepository.subscribe(roomId, (message) {
        // 중복 메시지 방지: 이미 존재하는 메시지인지 확인
        final isDuplicate = _messages.any((m) => m.id == message.id);
        if (!isDuplicate) {
          _messages.add(message);
          notifyListeners();
        }
      });
      _subscribedRoomId = roomId;
    } catch (e) {
      _error = 'WebSocket 구독 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  // 읽음 처리
  await markMessagesAsRead(roomId);
}
```

**주요 변경 사항:**
- 같은 채팅방 중복 구독 방지
- 이전 채팅방 자동 구독 해제
- 중복 메시지 ID 확인하여 추가 방지

**수정된 leaveRoom 메서드:**
```dart
void leaveRoom(String roomId) {
  if (_isConnected && _subscribedRoomId == roomId) {
    webSocketRepository.unsubscribe(roomId);
    _subscribedRoomId = null;
  }
  _currentRoom = null;
  _messages = [];
  _currentPage = 0;
  _hasMoreMessages = true;
  notifyListeners();
}
```

### 2. 올바른 표시 이름

**수정 파일:** `lib/presentation/pages/chat/chat_room_page.dart`

**변경 전:**
```dart
final displayName = widget.room.distributorName;
```

**변경 후:**
```dart
final authProvider = context.watch<AuthProvider>();
final userType = authProvider.user?.userType;

// userType에 따라 표시할 이름 결정
final displayName = userType == 'STORE_OWNER'
    ? widget.room.distributorName
    : widget.room.storeName;
```

**로직:**
- 가게 사장님 → 유통업체 이름 표시
- 유통업자 → 가게 이름 표시

### 3. 올바른 메시지 방향

**수정 파일:** `lib/presentation/pages/chat/chat_room_page.dart`

**변경 전:**
```dart
final isMe = false;
```

**변경 후:**
```dart
// 현재 사용자 ID와 비교
final authProvider = context.read<AuthProvider>();
final currentUserId = authProvider.user?.userType == 'STORE_OWNER'
    ? widget.room.storeId
    : widget.room.distributorId;
final isMe = message.senderId == currentUserId;
```

**로직:**
- 가게 사장님: `storeId`와 `senderId` 비교
- 유통업자: `distributorId`와 `senderId` 비교
- 일치하면 내 메시지 (오른쪽), 아니면 상대방 메시지 (왼쪽)

### 4. 채팅 목록 표시 이름

**수정 파일:** `lib/presentation/pages/chat/chat_list_page.dart`

**변경 전:**
```dart
final displayName = room.distributorName;
```

**변경 후:**
```dart
final authProvider = context.watch<AuthProvider>();
final userType = authProvider.user?.userType;

// userType에 따라 표시할 이름 결정
final displayName = userType == 'STORE_OWNER'
    ? room.distributorName
    : room.storeName;
```

## 🎯 동작 흐름

### 가게 사장님
```
1. 채팅 목록: 유통업체 이름들 표시
2. 채팅방 입장: 유통업체 이름 표시
3. 메시지 전송: 오른쪽에 파란색 말풍선
4. 메시지 수신: 왼쪽에 회색 말풍선
```

### 유통업자
```
1. 채팅 목록: 가게 이름들 표시
2. 채팅방 입장: 가게 이름 표시
3. 메시지 전송: 오른쪽에 파란색 말풍선
4. 메시지 수신: 왼쪽에 회색 말풍선
```

## 🧪 테스트 시나리오

### 시나리오 1: 가게 사장님
1. ✅ 가게 사장님으로 로그인
2. ✅ 채팅 목록에서 유통업체 이름 확인
3. ✅ 채팅방 입장 → 유통업체 이름 표시
4. ✅ 메시지 전송 → 오른쪽에 표시
5. ✅ 유통업자가 보낸 메시지 → 왼쪽에 표시

### 시나리오 2: 유통업자
1. ✅ 유통업자로 로그인
2. ✅ 채팅 목록에서 가게 이름 확인
3. ✅ 채팅방 입장 → 가게 이름 표시
4. ✅ 메시지 전송 → 오른쪽에 표시
5. ✅ 가게 사장님이 보낸 메시지 → 왼쪽에 표시

### 시나리오 3: 중복 메시지 방지
1. ✅ 채팅방 입장
2. ✅ 메시지 전송
3. ✅ 메시지가 한 번만 표시됨 (중복 없음)
4. ✅ 다른 채팅방으로 이동
5. ✅ 이전 채팅방 구독 자동 해제
6. ✅ 새 채팅방 구독

## 📝 주요 수정 파일

### 1. lib/presentation/providers/chat_provider.dart
- `_subscribedRoomId` 상태 변수 추가
- `enterRoom` 메서드: 중복 구독 방지, 이전 구독 해제, 중복 메시지 방지
- `leaveRoom` 메서드: 구독 ID 확인 후 해제

### 2. lib/presentation/pages/chat/chat_room_page.dart
- `displayName`: userType에 따라 올바른 이름 표시
- `isMe`: 현재 사용자 ID와 senderId 비교
- AuthProvider import 추가

### 3. lib/presentation/pages/chat/chat_list_page.dart
- `displayName`: userType에 따라 올바른 이름 표시
- AuthProvider import 추가

## 🎉 결과

이제 다음과 같이 정상 작동합니다:

1. ✅ 가게 사장님: 유통업체 이름 표시, 내 메시지 오른쪽
2. ✅ 유통업자: 가게 이름 표시, 내 메시지 오른쪽
3. ✅ 메시지 중복 없음
4. ✅ 채팅방 전환 시 이전 구독 자동 해제
5. ✅ 올바른 메시지 방향 표시

**유통업자 채팅 문제가 완전히 해결되었습니다!** 🎉

## 🔍 디버깅 팁

### 메시지 중복 확인
```dart
// ChatProvider의 subscribe 콜백에 로그 추가
webSocketRepository.subscribe(roomId, (message) {
  debugPrint('📨 Received message: ${message.id} - ${message.content}');
  final isDuplicate = _messages.any((m) => m.id == message.id);
  debugPrint('🔍 Is duplicate: $isDuplicate');
  if (!isDuplicate) {
    _messages.add(message);
    notifyListeners();
  }
});
```

### 사용자 타입 확인
```dart
// ChatRoomPage에서 로그 추가
debugPrint('👤 User type: $userType');
debugPrint('📛 Display name: $displayName');
debugPrint('🆔 Current user ID: $currentUserId');
debugPrint('📧 Message sender ID: ${message.senderId}');
debugPrint('✅ Is me: $isMe');
```

## ⚠️ 주의사항

### 1. AuthProvider 의존성
- ChatRoomPage와 ChatListPage에서 AuthProvider 필요
- main.dart에 AuthProvider가 등록되어 있어야 함

### 2. 채팅방 전환
- 채팅방 전환 시 이전 구독 자동 해제
- 새 채팅방 구독 전 이전 구독 정리

### 3. 메시지 ID
- 메시지 중복 확인은 ID 기반
- 서버에서 고유한 ID 생성 필요
