# ✅ 타이핑 인디케이터 구현 완료

## 📋 개요

채팅 기능에 "상대방이 입력 중..." 표시 기능이 추가되었습니다.
백엔드 API와 연동하여 실시간으로 타이핑 상태를 표시합니다.

---

## 🎯 구현된 기능

### 1. 실시간 타이핑 감지
- 사용자가 텍스트를 입력하면 자동으로 타이핑 이벤트 전송
- 2초간 입력이 없으면 자동으로 타이핑 중단 이벤트 전송
- 메시지 전송 시 즉시 타이핑 중단

### 2. 타이핑 상태 표시
- 상대방이 입력 중일 때 "OOO님이 입력 중" 표시
- 애니메이션 효과가 있는 점 3개 표시
- 채팅방 하단에 표시

### 3. Clean Architecture 준수
- Domain Layer: Repository 인터페이스 정의
- Data Layer: WebSocket 데이터 소스 구현
- Presentation Layer: Provider 상태 관리 및 UI

---

## 📁 수정된 파일

### Domain Layer
- `lib/domain/repositories/websocket_repository.dart`
  - `subscribeToTyping()` 메서드 추가
  - `unsubscribeFromTyping()` 메서드 추가
  - `sendTypingEvent()` 메서드 추가

### Data Layer
- `lib/data/datasources/websocket_data_source.dart`
  - 타이핑 관련 메서드 인터페이스 추가

- `lib/data/datasources/websocket_data_source_impl.dart`
  - 타이핑 이벤트 구독/전송 구현
  - `/topic/chat/{roomId}/typing` 구독
  - `/app/chat/{roomId}/typing` 전송

- `lib/data/repositories/websocket_repository_impl.dart`
  - 타이핑 메서드 구현 (데이터 소스 래핑)

### Presentation Layer
- `lib/presentation/providers/chat_provider.dart`
  - `_isOtherUserTyping` 상태 추가
  - `_typingUserName` 상태 추가
  - `sendTypingEvent()` 메서드 추가
  - `_handleTypingEvent()` 메서드 추가
  - 채팅방 입장 시 타이핑 이벤트 구독
  - 채팅방 퇴장 시 타이핑 구독 해제

- `lib/presentation/widgets/chat/typing_indicator.dart` (신규)
  - 타이핑 인디케이터 UI 위젯
  - 애니메이션 효과

- `lib/presentation/pages/chat/chat_room_page.dart`
  - TextField에 타이핑 감지 리스너 추가
  - 타이핑 인디케이터 UI 통합
  - 2초 디바운싱 타이머 구현

---

## 🔄 동작 흐름

### 타이핑 시작
```
사용자 A가 텍스트 입력
  ↓
TextField의 onChanged 감지
  ↓
ChatProvider.sendTypingEvent(isTyping: true)
  ↓
WebSocket: /app/chat/{roomId}/typing 전송
  ↓
백엔드 서버 처리
  ↓
WebSocket: /topic/chat/{roomId}/typing 브로드캐스트
  ↓
사용자 B가 수신
  ↓
ChatProvider._handleTypingEvent()
  ↓
UI 업데이트: "사용자 A님이 입력 중" 표시
```

### 타이핑 중단
```
2초간 입력 없음 OR 메시지 전송
  ↓
타이머 만료 또는 전송 버튼 클릭
  ↓
ChatProvider.sendTypingEvent(isTyping: false)
  ↓
WebSocket: /app/chat/{roomId}/typing 전송
  ↓
백엔드 서버 처리
  ↓
사용자 B가 수신
  ↓
UI 업데이트: 타이핑 인디케이터 제거
```

---

## 💻 코드 예시

### 1. 타이핑 이벤트 전송 (자동)
```dart
// TextField에 리스너가 자동으로 처리
// 사용자가 입력하면 자동으로 전송됨
_messageController.addListener(_onTextChanged);
```

### 2. 타이핑 상태 확인
```dart
final chatProvider = context.watch<ChatProvider>();

if (chatProvider.isOtherUserTyping) {
  // 상대방이 입력 중
  print('${chatProvider.typingUserName}님이 입력 중');
}
```

### 3. 타이핑 인디케이터 UI
```dart
// 채팅방 하단에 자동으로 표시
if (provider.isOtherUserTyping)
  TypingIndicator(
    userName: provider.typingUserName,
  ),
```

---

## 🎨 UI 특징

### 타이핑 인디케이터
- **위치**: 채팅 메시지 목록 하단
- **디자인**: 회색 둥근 배경에 텍스트와 애니메이션 점
- **텍스트**: "OOO님이 입력 중" (userName이 있는 경우)
- **애니메이션**: 3개의 점이 순차적으로 페이드 인/아웃

### 애니메이션 효과
- 1.5초 주기로 반복
- 각 점이 0.2초 간격으로 애니메이션
- 부드러운 opacity 변화

---

## ⚙️ 설정 값

### 타이핑 타임아웃
```dart
// 2초간 입력이 없으면 자동으로 타이핑 중단
Timer(const Duration(seconds: 2), () {
  // 타이핑 중단 이벤트 전송
});
```

### Rate Limiting
현재는 클라이언트에서 2초 디바운싱으로 처리:
- 입력할 때마다 타이머 리셋
- 2초 후에만 타이핑 중단 이벤트 전송
- 불필요한 이벤트 전송 최소화

---

## 🧪 테스트 방법

### 1. 기본 동작 테스트

**준비:**
1. 두 개의 디바이스/에뮬레이터 준비
2. 각각 다른 사용자로 로그인 (예: store1, dist1)
3. 같은 채팅방 입장

**테스트 시나리오:**
1. **타이핑 시작**
   - 디바이스 A에서 텍스트 입력 시작
   - 디바이스 B에서 "OOO님이 입력 중" 표시 확인

2. **타이핑 중단 (자동)**
   - 디바이스 A에서 입력 중단 (2초 대기)
   - 디바이스 B에서 타이핑 인디케이터 사라짐 확인

3. **메시지 전송**
   - 디바이스 A에서 메시지 전송
   - 디바이스 B에서 타이핑 인디케이터 즉시 사라짐 확인
   - 메시지 수신 확인

4. **빠른 입력**
   - 디바이스 A에서 연속으로 빠르게 입력
   - 디바이스 B에서 타이핑 인디케이터가 계속 표시됨 확인
   - 2초 후 자동으로 사라짐 확인

### 2. 엣지 케이스 테스트

**채팅방 퇴장:**
1. 디바이스 A에서 입력 중
2. 디바이스 A에서 뒤로가기 (채팅방 퇴장)
3. 디바이스 B에서 타이핑 인디케이터 사라짐 확인

**WebSocket 연결 끊김:**
1. 디바이스 A에서 입력 중
2. 네트워크 끊기 (비행기 모드)
3. 디바이스 B에서 타이핑 인디케이터 유지 (서버 타임아웃까지)

**앱 백그라운드:**
1. 디바이스 A에서 입력 중
2. 홈 버튼 눌러 백그라운드로 이동
3. dispose()에서 타이핑 중단 이벤트 전송됨

---

## 🐛 트러블슈팅

### 문제: 타이핑 인디케이터가 표시되지 않음

**확인 사항:**
1. WebSocket 연결 상태 확인
   ```dart
   print('WebSocket 연결: ${chatProvider.isConnected}');
   ```

2. 타이핑 이벤트 구독 확인
   ```
   로그에서 "✅ 타이핑 이벤트 구독 완료" 메시지 확인
   ```

3. 백엔드 API 확인
   ```bash
   # 백엔드 로그 확인
   tail -f boot-run.log | grep -i typing
   ```

### 문제: 자신의 타이핑도 표시됨

**원인:** 백엔드에서 자신에게도 브로드캐스트하는 경우

**해결:** 백엔드에서 이미 처리되어야 하지만, 클라이언트에서도 필터링 가능:
```dart
void _handleTypingEvent(Map<String, dynamic> event) {
  final userId = event['userId'] as String?;
  final authProvider = context.read<AuthProvider>();
  final currentUserId = authProvider.user?.userType == 'STORE_OWNER'
      ? authProvider.user?.storeId
      : authProvider.user?.distributorId;
  
  // 자신의 이벤트는 무시
  if (userId == currentUserId) {
    return;
  }
  
  // 나머지 처리...
}
```

### 문제: 타이핑 인디케이터가 사라지지 않음

**원인:** 타이핑 중단 이벤트가 전송되지 않음

**해결:**
1. dispose()에서 타이핑 중단 이벤트 전송 확인
2. 2초 타이머가 정상 작동하는지 확인
3. 메시지 전송 시 타이핑 중단 이벤트 전송 확인

### 문제: 타이핑 이벤트가 너무 자주 전송됨

**현재 구현:** 2초 디바운싱으로 이미 최적화됨

**추가 최적화 (필요시):**
```dart
DateTime? _lastTypingSent;

void _onTextChanged() {
  final now = DateTime.now();
  
  // 500ms 이내에는 재전송하지 않음
  if (_lastTypingSent != null && 
      now.difference(_lastTypingSent!).inMilliseconds < 500) {
    return;
  }
  
  _lastTypingSent = now;
  // 타이핑 이벤트 전송...
}
```

---

## 📊 성능 고려사항

### 네트워크 트래픽
- **타이핑 시작**: 1회 전송
- **타이핑 중**: 전송 없음 (디바운싱)
- **타이핑 중단**: 1회 전송 (2초 후 또는 메시지 전송 시)

**예시:**
- 10초간 입력: 총 2회 전송 (시작 1회 + 중단 1회)
- 메시지 전송: 총 2회 전송 (시작 1회 + 전송 시 중단 1회)

### 메모리 사용
- 타이핑 상태: 2개의 변수 (`bool`, `String?`)
- 타이머: 1개 (`Timer?`)
- 애니메이션: 1개 (`AnimationController`)

### 배터리 영향
- 애니메이션은 타이핑 중일 때만 실행
- 타이핑 중단 시 애니메이션 자동 중지
- 최소한의 배터리 소모

---

## 🔄 향후 개선 사항

### 1. 그룹 채팅 지원
현재는 1:1 채팅 기준으로 구현됨. 그룹 채팅의 경우:
```dart
// 여러 사용자가 동시에 입력 중
if (provider.typingUsers.length > 0) {
  TypingIndicator(
    userNames: provider.typingUsers, // ["홍길동", "김철수"]
  );
}
// UI: "홍길동, 김철수님이 입력 중"
```

### 2. 타이핑 타임아웃 설정
```dart
// 사용자가 설정 가능하도록
const typingTimeout = Duration(seconds: 2); // 기본값
```

### 3. 서버 측 타임아웃
백엔드에서 10초 이상 타이핑 상태가 유지되면 자동으로 중단 처리

### 4. 오프라인 처리
```dart
// WebSocket 연결이 끊어졌을 때
if (!chatProvider.isConnected) {
  // 타이핑 이벤트 전송 안 함
  return;
}
```

---

## ✅ 체크리스트

### 백엔드 (완료 ✅)
- [x] `/app/chat/{roomId}/typing` 엔드포인트 구현
- [x] `/topic/chat/{roomId}/typing` 브로드캐스트 구현
- [x] 채팅방 접근 권한 검증
- [x] 사용자 정보 자동 설정

### 프론트엔드 (완료 ✅)
- [x] WebSocket 데이터 소스에 타이핑 메서드 추가
- [x] Repository에 타이핑 메서드 추가
- [x] ChatProvider에 타이핑 상태 관리 추가
- [x] 타이핑 인디케이터 UI 위젯 생성
- [x] 채팅방 페이지에 타이핑 감지 통합
- [x] 2초 디바운싱 구현
- [x] 메시지 전송 시 타이핑 중단 처리
- [x] 채팅방 퇴장 시 타이핑 중단 처리

---

## 📝 사용 방법

### 개발자용

**타이핑 이벤트 수동 전송:**
```dart
final chatProvider = context.read<ChatProvider>();

// 타이핑 시작
chatProvider.sendTypingEvent(
  roomId: 'room123',
  isTyping: true,
);

// 타이핑 중단
chatProvider.sendTypingEvent(
  roomId: 'room123',
  isTyping: false,
);
```

**타이핑 상태 확인:**
```dart
final chatProvider = context.watch<ChatProvider>();

if (chatProvider.isOtherUserTyping) {
  print('상대방이 입력 중: ${chatProvider.typingUserName}');
}
```

### 사용자용

**자동으로 작동:**
1. 채팅방에서 메시지 입력 시작
2. 상대방 화면에 자동으로 "입력 중" 표시
3. 2초간 입력 없으면 자동으로 사라짐
4. 메시지 전송 시 즉시 사라짐

---

## 🎉 완료!

타이핑 인디케이터 기능이 완전히 구현되었습니다.

**주요 특징:**
- ✅ 실시간 타이핑 감지
- ✅ 2초 디바운싱으로 최적화
- ✅ 애니메이션 효과
- ✅ Clean Architecture 준수
- ✅ 메모리 효율적
- ✅ 배터리 친화적

**테스트 방법:**
1. 두 개의 디바이스로 로그인
2. 같은 채팅방 입장
3. 한쪽에서 텍스트 입력
4. 다른 쪽에서 "입력 중" 표시 확인

---

## 📞 문의

구현 중 문제가 있으면 다음을 확인하세요:

1. **WebSocket 연결 상태**
   ```dart
   print('연결 상태: ${chatProvider.isConnected}');
   ```

2. **백엔드 로그**
   ```bash
   tail -f boot-run.log | grep -i typing
   ```

3. **Flutter 로그**
   ```
   "📤 타이핑 이벤트 전송" 메시지 확인
   "📥 타이핑 이벤트 수신" 메시지 확인
   ```
