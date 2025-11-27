# 채팅 기능 구현 가이드

## 📋 개요

SOLID 원칙을 적용한 Clean Architecture 기반 채팅 기능 구현이 완료되었습니다.

## 🏗️ 아키텍처

### SOLID 원칙 적용

1. **Single Responsibility Principle (단일 책임 원칙)**
   - 각 클래스는 하나의 책임만 가집니다
   - `ChatRemoteDataSource`: HTTP 통신만 담당
   - `WebSocketDataSource`: WebSocket 통신만 담당
   - `ChatRepository`: 데이터 소스 조율 및 에러 처리
   - `ChatProvider`: 상태 관리만 담당

2. **Open/Closed Principle (개방-폐쇄 원칙)**
   - `MessageType` enum으로 새로운 메시지 타입 추가 가능
   - `MessageBubble` 위젯에서 타입별 UI 확장 가능

3. **Liskov Substitution Principle (리스코프 치환 원칙)**
   - 인터페이스 기반 설계로 구현체 교체 가능
   - `ChatRemoteDataSource`, `WebSocketDataSource` 인터페이스

4. **Interface Segregation Principle (인터페이스 분리 원칙)**
   - REST API와 WebSocket을 별도 인터페이스로 분리
   - 필요한 기능만 노출

5. **Dependency Inversion Principle (의존성 역전 원칙)**
   - 구체적인 구현이 아닌 추상화에 의존
   - Repository 인터페이스를 통한 의존성 주입

## 📁 프로젝트 구조

```
lib/
├── domain/
│   ├── entities/
│   │   ├── chat_room.dart
│   │   ├── chat_message.dart
│   │   └── paginated_messages.dart
│   ├── repositories/
│   │   ├── chat_repository.dart
│   │   └── websocket_repository.dart
│   └── usecases/
│       ├── get_chat_rooms.dart
│       ├── create_or_get_chat_room.dart
│       ├── get_messages.dart
│       ├── mark_messages_as_read.dart
│       └── send_message.dart
├── data/
│   ├── models/
│   │   ├── chat_room_model.dart
│   │   ├── chat_message_model.dart
│   │   └── paginated_messages_model.dart
│   ├── datasources/
│   │   ├── chat_remote_data_source.dart
│   │   ├── chat_remote_data_source_impl.dart
│   │   ├── websocket_data_source.dart
│   │   └── websocket_data_source_impl.dart
│   └── repositories/
│       ├── chat_repository_impl.dart
│       └── websocket_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── chat_provider.dart
    ├── pages/
    │   └── chat/
    │       ├── chat_list_page.dart
    │       └── chat_room_page.dart
    └── widgets/
        └── chat/
            └── message_bubble.dart
```

## 🚀 사용 방법

### 1. Provider 등록 (main.dart)

```dart
import 'package:provider/provider.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InjectionContainer.getChatProvider(),
        ),
        // ... 다른 providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. WebSocket 연결 (로그인 후)

```dart
// 로그인 성공 후
final chatProvider = context.read<ChatProvider>();
final authProvider = context.read<AuthProvider>();
final accessToken = authProvider.user?.accessToken;
if (accessToken != null) {
  await chatProvider.connectWebSocket(accessToken);
}
```

### 3. 채팅 목록 화면 이동

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ChatListPage(),
  ),
);
```

### 4. 특정 상대와 채팅 시작

```dart
// 견적 요청 화면이나 주문 상세 화면에서
final chatProvider = context.read<ChatProvider>();
final room = await chatProvider.createOrGetRoom(
  storeId: 'store1',
  distributorId: 'dist1',
);

if (room != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatRoomPage(room: room),
    ),
  );
}
```

## 🔧 TODO: 추가 구현 필요 사항

### 1. 현재 사용자 정보 연동

`ChatRoomPage`와 `MessageBubble`에서 현재 사용자 ID를 확인하여 내 메시지인지 판단:

```dart
// TODO: AuthProvider에서 현재 사용자 정보 가져오기
final currentUserId = context.read<AuthProvider>().userId;
final isMe = message.senderId == currentUserId;
```

### 2. UserType에 따른 이름 표시

`ChatListPage`와 `ChatRoomPage`에서 사용자 타입에 따라 표시할 이름 결정:

```dart
// TODO: AuthProvider에서 userType 가져오기
final userType = context.read<AuthProvider>().userType;
final displayName = userType == 'STORE_OWNER' 
    ? room.distributorName 
    : room.storeName;
```

### 3. 앱 생명주기 관리

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final chatProvider = context.read<ChatProvider>();
    
    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 이동
      chatProvider.disconnectWebSocket();
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 복귀
      final accessToken = context.read<AuthProvider>().accessToken;
      if (accessToken != null) {
        chatProvider.connectWebSocket(accessToken);
      }
    }
  }
}
```

### 4. 에러 처리 UI

```dart
// ChatProvider의 error를 감지하여 SnackBar 표시
if (provider.error != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error!)),
    );
    provider.clearError();
  });
}
```

### 5. 메시지 타입별 특수 UI

`MessageBubble`의 `_buildSpecialMessage`를 확장하여:
- 주문 정보 카드 표시
- 견적서 카드 표시
- "주문하기" 버튼 추가
- metadata 파싱 및 활용

```dart
// metadata 파싱 예시
if (message.metadata != null) {
  final metadata = jsonDecode(message.metadata!);
  final orderId = metadata['orderId'];
  // 주문 상세 화면으로 이동하는 버튼 추가
}
```

## 🧪 테스트

### 테스트 계정
- 매장: `username=store1`, `password=password123`
- 유통업체: `username=dist1`, `password=password123`

### 테스트 시나리오

1. **채팅방 목록 조회**
   - 로그인 후 채팅 목록 화면 진입
   - 채팅방 목록 표시 확인
   - 읽지 않은 메시지 배지 확인

2. **채팅방 입장**
   - 채팅방 선택
   - 메시지 목록 로드 확인
   - WebSocket 연결 상태 확인

3. **메시지 전송**
   - 텍스트 입력 후 전송
   - 실시간으로 메시지 수신 확인

4. **무한 스크롤**
   - 스크롤을 위로 올려 이전 메시지 로드
   - 페이징 동작 확인

5. **읽음 처리**
   - 채팅방 입장 시 읽지 않은 메시지 수 감소 확인

## 📝 주의사항

1. **WebSocket 연결**
   - 로그인 후 반드시 `connectWebSocket()` 호출
   - 로그아웃 시 `disconnectWebSocket()` 호출

2. **메모리 관리**
   - 채팅방 퇴장 시 `leaveRoom()` 호출하여 구독 해제
   - 메시지 목록이 너무 길어지지 않도록 관리

3. **에러 처리**
   - 네트워크 에러 시 재시도 로직
   - WebSocket 연결 끊김 시 자동 재연결 (현재 미구현)

4. **보안**
   - AccessToken을 secure storage에 저장
   - WebSocket 연결 시 토큰 인증

## 🔄 향후 개선 사항

1. **자동 재연결**
   - WebSocket 연결 끊김 시 exponential backoff로 재연결

2. **푸시 알림**
   - 앱이 백그라운드일 때 새 메시지 알림

3. **이미지 전송**
   - 이미지 업로드 및 표시 기능

4. **메시지 검색**
   - 채팅 내용 검색 기능

5. **읽음 표시**
   - 상대방이 메시지를 읽었는지 표시

6. **타이핑 인디케이터**
   - 상대방이 입력 중일 때 표시

## 📚 참고 문서

- [FLUTTER_CHAT_API_GUIDE.md](./FLUTTER_CHAT_API_GUIDE.md) - 백엔드 API 가이드
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
