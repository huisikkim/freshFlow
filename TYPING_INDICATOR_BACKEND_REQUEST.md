# 타이핑 인디케이터 백엔드 구현 요청

## 📋 개요
채팅 기능에 "상대방이 입력 중..." 표시 기능을 추가하기 위한 백엔드 작업 요청입니다.

## 🎯 요구사항

### 1. 새로운 WebSocket 엔드포인트 추가

**엔드포인트:** `/app/chat/{roomId}/typing`

**기능:** 
- 사용자가 입력을 시작/중단할 때 타이핑 상태를 전송
- 같은 채팅방의 상대방에게만 타이핑 상태를 브로드캐스트

### 2. 타이핑 이벤트 DTO

```java
// TypingEvent.java
public class TypingEvent {
    private String roomId;
    private String userId;      // 입력 중인 사용자 ID
    private String userName;    // 입력 중인 사용자 이름 (선택사항)
    private boolean isTyping;   // true: 입력 중, false: 입력 중단
    private LocalDateTime timestamp;
    
    // getters, setters, constructors
}
```

### 3. WebSocket 컨트롤러 메서드

```java
@Controller
public class ChatWebSocketController {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    /**
     * 타이핑 상태 처리
     * 클라이언트가 /app/chat/{roomId}/typing 으로 전송
     * 서버는 /topic/chat/{roomId}/typing 으로 브로드캐스트
     */
    @MessageMapping("/chat/{roomId}/typing")
    public void handleTyping(
        @DestinationVariable String roomId,
        @Payload TypingEvent event,
        Principal principal
    ) {
        // 현재 사용자 정보 설정
        event.setUserId(principal.getName());
        event.setTimestamp(LocalDateTime.now());
        
        // 같은 채팅방의 다른 사용자들에게 전송
        messagingTemplate.convertAndSend(
            "/topic/chat/" + roomId + "/typing",
            event
        );
    }
}
```

### 4. WebSocket 설정 업데이트

기존 `WebSocketConfig.java`에 타이핑 토픽 추가 (이미 설정되어 있을 수 있음):

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");  // 이미 있음
        config.setApplicationDestinationPrefixes("/app");  // 이미 있음
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws/chat")
                .setAllowedOrigins("*")
                .withSockJS();  // 이미 있음
    }
}
```

## 📡 통신 흐름

### 클라이언트 → 서버 (타이핑 시작)
```json
// SEND to: /app/chat/{roomId}/typing
{
  "roomId": "room123",
  "isTyping": true
}
```

### 서버 → 클라이언트 (브로드캐스트)
```json
// SUBSCRIBE to: /topic/chat/{roomId}/typing
{
  "roomId": "room123",
  "userId": "user456",
  "userName": "홍길동",
  "isTyping": true,
  "timestamp": "2025-11-28T10:30:00"
}
```

### 클라이언트 → 서버 (타이핑 중단)
```json
// SEND to: /app/chat/{roomId}/typing
{
  "roomId": "room123",
  "isTyping": false
}
```

## 🔒 보안 고려사항

### 1. 권한 검증
```java
@MessageMapping("/chat/{roomId}/typing")
public void handleTyping(
    @DestinationVariable String roomId,
    @Payload TypingEvent event,
    Principal principal
) {
    // 사용자가 해당 채팅방에 접근 권한이 있는지 확인
    if (!chatRoomService.hasAccess(roomId, principal.getName())) {
        throw new AccessDeniedException("채팅방 접근 권한이 없습니다.");
    }
    
    // ... 나머지 로직
}
```

### 2. Rate Limiting (선택사항)
- 타이핑 이벤트가 너무 자주 전송되지 않도록 제한
- 예: 1초에 최대 2회

## 🧪 테스트 방법

### 1. WebSocket 클라이언트로 테스트

```javascript
// 연결
const socket = new SockJS('http://localhost:8080/ws/chat');
const stompClient = Stomp.over(socket);

stompClient.connect({
  'Authorization': 'Bearer YOUR_TOKEN'
}, function(frame) {
  
  // 타이핑 이벤트 구독
  stompClient.subscribe('/topic/chat/room123/typing', function(message) {
    console.log('타이핑 이벤트:', JSON.parse(message.body));
  });
  
  // 타이핑 시작 전송
  stompClient.send('/app/chat/room123/typing', {}, JSON.stringify({
    roomId: 'room123',
    isTyping: true
  }));
  
  // 3초 후 타이핑 중단 전송
  setTimeout(() => {
    stompClient.send('/app/chat/room123/typing', {}, JSON.stringify({
      roomId: 'room123',
      isTyping: false
    }));
  }, 3000);
});
```

### 2. 예상 로그

```
[INFO] WebSocket connection established: user456
[INFO] Subscribed to /topic/chat/room123/typing
[INFO] Typing event received: roomId=room123, userId=user456, isTyping=true
[INFO] Broadcasting typing event to /topic/chat/room123/typing
[INFO] Typing event received: roomId=room123, userId=user456, isTyping=false
```

## 📝 추가 고려사항

### 1. 데이터베이스 저장 불필요
- 타이핑 이벤트는 실시간 상태 정보이므로 DB에 저장하지 않음
- 메모리에서만 처리하고 브로드캐스트

### 2. 타임아웃 처리 (선택사항)
서버에서 타이핑 상태가 일정 시간(예: 10초) 이상 유지되면 자동으로 중단 처리:

```java
// 선택사항: 서버 측 타임아웃 관리
private final Map<String, ScheduledFuture<?>> typingTimeouts = new ConcurrentHashMap<>();

@MessageMapping("/chat/{roomId}/typing")
public void handleTyping(...) {
    String key = roomId + ":" + principal.getName();
    
    if (event.isTyping()) {
        // 기존 타임아웃 취소
        ScheduledFuture<?> existing = typingTimeouts.get(key);
        if (existing != null) {
            existing.cancel(false);
        }
        
        // 10초 후 자동 중단
        ScheduledFuture<?> timeout = scheduler.schedule(() -> {
            event.setIsTyping(false);
            messagingTemplate.convertAndSend(
                "/topic/chat/" + roomId + "/typing",
                event
            );
        }, 10, TimeUnit.SECONDS);
        
        typingTimeouts.put(key, timeout);
    } else {
        // 타임아웃 취소
        ScheduledFuture<?> existing = typingTimeouts.remove(key);
        if (existing != null) {
            existing.cancel(false);
        }
    }
    
    // 브로드캐스트
    messagingTemplate.convertAndSend(...);
}
```

### 3. 여러 사용자 동시 입력
- 현재 구조는 1:1 채팅 기준
- 그룹 채팅의 경우 여러 사용자가 동시에 입력 가능
- 프론트엔드에서 "홍길동, 김철수가 입력 중..." 형태로 표시 가능

## ✅ 체크리스트

백엔드 개발자가 확인할 사항:

- [ ] `TypingEvent` DTO 클래스 생성
- [ ] `ChatWebSocketController`에 `handleTyping` 메서드 추가
- [ ] `/app/chat/{roomId}/typing` 엔드포인트 동작 확인
- [ ] `/topic/chat/{roomId}/typing` 구독 가능 확인
- [ ] 채팅방 접근 권한 검증 추가
- [ ] WebSocket 클라이언트로 테스트 완료
- [ ] 프론트엔드 팀에 API 문서 전달

## 📚 참고 자료

- 기존 채팅 메시지 전송 로직 참고
- Spring WebSocket 문서: https://docs.spring.io/spring-framework/reference/web/websocket.html
- STOMP 프로토콜: https://stomp.github.io/

## 🔄 프론트엔드 연동 정보

백엔드 작업 완료 후 프론트엔드에서 다음과 같이 사용:

```dart
// 구독
stompClient.subscribe(
  destination: '/topic/chat/$roomId/typing',
  callback: (frame) {
    // 타이핑 상태 처리
  },
);

// 전송
stompClient.send(
  destination: '/app/chat/$roomId/typing',
  body: json.encode({
    'roomId': roomId,
    'isTyping': true,
  }),
);
```

---

**작업 우선순위:** 중간 (기존 채팅 기능은 정상 작동, UX 개선 기능)

**예상 작업 시간:** 1-2시간

**의존성:** 기존 WebSocket 채팅 기능 (이미 구현됨)
