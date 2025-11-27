# 🔧 WebSocket 연결 문제 해결 가이드

## ❌ 발생한 문제

**에러 메시지:** `Exception: WebSocket is not connected`

**증상:**
- 유통업자가 채팅 메시지를 보내려고 할 때 에러 발생
- 메시지가 전송되지 않음
- WebSocket이 연결되지 않은 상태

## 🔍 원인 분석

### 1. 로그인 시 WebSocket 연결 실패
- 로그인 페이지에서 WebSocket 연결을 시도하지만 실패할 수 있음
- 네트워크 문제, 서버 문제 등으로 연결 실패 가능

### 2. 채팅방 입장 시 연결 확인 부족
- `enterRoom` 메서드에서 연결 상태만 확인하고 재연결 시도 없음
- 연결되지 않은 상태로 채팅방 진입

### 3. 메시지 전송 시 연결 확인 부족
- `sendTextMessage`에서 연결 상태 확인 없이 전송 시도
- WebSocket이 연결되지 않은 상태에서 에러 발생

## ✅ 해결 방법

### 1. 채팅방 입장 시 자동 재연결

**수정 파일:** `lib/presentation/providers/chat_provider.dart`

```dart
/// 채팅방 입장 (구독 + 읽음 처리)
Future<void> enterRoom(String roomId, String accessToken) async {
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
        _messages.add(message);
        notifyListeners();
      });
    } catch (e) {
      _error = 'WebSocket 구독 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  // 읽음 처리
  await markMessagesAsRead(roomId);
}
```

**변경 사항:**
- `enterRoom` 메서드에 `accessToken` 파라미터 추가
- 연결되지 않았으면 자동으로 재연결 시도
- 에러 발생 시 에러 메시지 설정

### 2. 메시지 전송 시 연결 확인

**수정 파일:** `lib/presentation/providers/chat_provider.dart`

```dart
/// 메시지 전송
Future<void> sendTextMessage({
  required String roomId,
  required String content,
  String messageType = 'TEXT',
  String? metadata,
}) async {
  // WebSocket 연결 확인
  if (!_isConnected) {
    _error = 'WebSocket이 연결되지 않았습니다. 잠시 후 다시 시도해주세요.';
    notifyListeners();
    return;
  }

  final result = await sendMessage(
    roomId: roomId,
    content: content,
    messageType: messageType,
    metadata: metadata,
  );

  result.fold(
    (failure) {
      _error = failure.message;
      notifyListeners();
    },
    (_) {
      // 메시지 전송 성공 (WebSocket으로 수신됨)
    },
  );
}
```

**변경 사항:**
- 메시지 전송 전 연결 상태 확인
- 연결되지 않았으면 에러 메시지 표시하고 리턴

### 3. ChatRoomPage에서 accessToken 전달

**수정 파일:** `lib/presentation/pages/chat/chat_room_page.dart`

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final accessToken = authProvider.user?.accessToken ?? '';
    
    chatProvider.loadMessages(widget.room.roomId, refresh: true);
    await chatProvider.enterRoom(widget.room.roomId, accessToken);

    // 스크롤 리스너 (무한 스크롤)
    _scrollController.addListener(_onScroll);
  });
}
```

**변경 사항:**
- AuthProvider에서 accessToken 가져오기
- `enterRoom` 호출 시 accessToken 전달
- async/await 사용

### 4. 에러 메시지 UI 표시

**수정 파일:** `lib/presentation/pages/chat/chat_room_page.dart`

```dart
void _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final chatProvider = context.read<ChatProvider>();
  
  await chatProvider.sendTextMessage(
    roomId: widget.room.roomId,
    content: text,
  );

  // 에러가 있으면 표시
  if (chatProvider.error != null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.error!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '재연결',
            textColor: Colors.white,
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final accessToken = authProvider.user?.accessToken ?? '';
              await chatProvider.connectWebSocket(accessToken);
            },
          ),
        ),
      );
      chatProvider.clearError();
    }
  } else {
    _messageController.clear();
  }
}
```

**변경 사항:**
- 메시지 전송 후 에러 확인
- 에러가 있으면 SnackBar로 표시
- "재연결" 버튼 제공

### 5. 연결 상태 UI 표시

**수정 파일:** `lib/presentation/pages/chat/chat_room_page.dart`

```dart
appBar: AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(displayName),
      Consumer<ChatProvider>(
        builder: (context, provider, child) {
          return Text(
            provider.isConnected ? '온라인' : '오프라인',
            style: TextStyle(
              fontSize: 12,
              color: provider.isConnected ? Colors.green : Colors.grey,
            ),
          );
        },
      ),
    ],
  ),
  elevation: 0,
),
```

**변경 사항:**
- AppBar에 연결 상태 표시
- 온라인/오프라인 텍스트와 색상으로 구분

## 🎯 동작 흐름

### 정상 흐름
```
1. 로그인 → WebSocket 연결 시도
2. 채팅방 입장 → 연결 확인 → (연결됨) 구독
3. 메시지 전송 → 연결 확인 → (연결됨) 전송 성공
```

### 재연결 흐름
```
1. 로그인 → WebSocket 연결 실패
2. 채팅방 입장 → 연결 확인 → (연결 안됨) 재연결 시도 → 구독
3. 메시지 전송 → 연결 확인 → (연결됨) 전송 성공
```

### 에러 처리 흐름
```
1. 로그인 → WebSocket 연결 실패
2. 채팅방 입장 → 연결 확인 → (연결 안됨) 재연결 실패
3. 메시지 전송 → 연결 확인 → (연결 안됨) 에러 메시지 표시
4. 사용자가 "재연결" 버튼 클릭 → 재연결 시도
```

## 🧪 테스트 방법

### 1. 정상 시나리오
1. 앱 실행 및 로그인
2. 채팅방 입장
3. AppBar에서 "온라인" 상태 확인
4. 메시지 전송 → 정상 전송 확인

### 2. 재연결 시나리오
1. 앱 실행 및 로그인 (네트워크 불안정)
2. 채팅방 입장 → 자동 재연결 시도
3. AppBar에서 "온라인" 상태 확인
4. 메시지 전송 → 정상 전송 확인

### 3. 에러 시나리오
1. 앱 실행 및 로그인 (네트워크 차단)
2. 채팅방 입장 → 재연결 실패
3. AppBar에서 "오프라인" 상태 확인
4. 메시지 전송 시도 → 에러 메시지 표시
5. "재연결" 버튼 클릭 → 재연결 시도

## 📝 주의사항

### WebSocket 서버 URL 확인
**파일:** `lib/core/constants/api_constants.dart`

```dart
// WebSocket URL
static String get wsUrl => isDevelopment 
    ? localBaseUrl.replaceFirst('http', 'ws')
    : devBaseUrl.replaceFirst('https', 'wss');
```

- 개발 환경: `ws://localhost:8080`
- 프로덕션: `wss://your-server.com`
- HTTP → WS, HTTPS → WSS 변환 확인

### 서버 연결 확인
```bash
# WebSocket 서버 테스트
wscat -c ws://localhost:8080/ws/chat
```

### 로그 확인
```dart
// ChatProvider에서 디버그 로그 추가
debugPrint('WebSocket connected: $_isConnected');
debugPrint('Sending message to room: $roomId');
```

## 🚀 배포 전 체크리스트

- [x] 채팅방 입장 시 자동 재연결
- [x] 메시지 전송 시 연결 확인
- [x] 에러 메시지 UI 표시
- [x] 연결 상태 UI 표시
- [x] AuthProvider에서 accessToken 전달
- [x] 에러 없이 빌드 성공

## 🎉 결과

이제 다음과 같이 작동합니다:

1. ✅ 로그인 시 WebSocket 연결 시도
2. ✅ 채팅방 입장 시 연결되지 않았으면 자동 재연결
3. ✅ 메시지 전송 전 연결 상태 확인
4. ✅ 연결되지 않았으면 에러 메시지 표시
5. ✅ "재연결" 버튼으로 수동 재연결 가능
6. ✅ AppBar에서 연결 상태 실시간 확인

**WebSocket 연결 문제가 완전히 해결되었습니다!** 🎉
