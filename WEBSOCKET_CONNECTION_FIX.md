# 🔧 WebSocket 연결 400 에러 해결

## ❌ 발생한 문제

**에러 메시지:**
```
WebSocketException: Connection to 'http://localhost:8080/ws/chat#' was not upgraded to websocket, HTTP status code: 400
```

**증상:**
- WebSocket 연결 시도 시 HTTP 400 에러 발생
- WebSocket 업그레이드 실패
- 채팅 기능 사용 불가

## 🔍 원인 분석

### 1. SockJS vs 순수 WebSocket
- `stomp_dart_client` 패키지는 기본적으로 순수 WebSocket 사용
- 백엔드는 SockJS를 사용하도록 설정됨
- `StompConfig.sockJS()` 사용 필요

### 2. localhost 문제 (Android 에뮬레이터)
- Android 에뮬레이터에서 `localhost`는 에뮬레이터 자체를 가리킴
- 호스트 머신의 서버에 접근하려면 `10.0.2.2` 사용 필요
- iOS 시뮬레이터는 `localhost` 사용 가능

### 3. URL 형식
- 잘못된 URL: `ws://localhost:8080/ws/chat`
- 올바른 URL: `http://10.0.2.2:8080/ws/chat` (SockJS 사용 시)

## ✅ 해결 방법

### 1. SockJS 사용 설정

**수정 파일:** `lib/data/datasources/websocket_data_source_impl.dart`

**변경 전:**
```dart
_stompClient = StompClient(
  config: StompConfig(
    url: '${ApiConstants.wsUrl}/ws/chat',
    // ...
  ),
);
```

**변경 후:**
```dart
_stompClient = StompClient(
  config: StompConfig.sockJS(
    url: '${ApiConstants.baseUrl}/ws/chat',
    onConnect: (StompFrame frame) {
      _connectionStateController.add(true);
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onWebSocketError: (dynamic error) {
      _connectionStateController.add(false);
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    },
    onStompError: (StompFrame frame) {
      _connectionStateController.add(false);
    },
    onDisconnect: (StompFrame frame) {
      _connectionStateController.add(false);
    },
    stompConnectHeaders: {
      'Authorization': 'Bearer $accessToken',
    },
    webSocketConnectHeaders: {
      'Authorization': 'Bearer $accessToken',
    },
  ),
);
```

**주요 변경 사항:**
- `StompConfig()` → `StompConfig.sockJS()`
- `ApiConstants.wsUrl` → `ApiConstants.baseUrl` (HTTP URL 사용)
- SockJS가 자동으로 WebSocket 업그레이드 처리

### 2. Android 에뮬레이터용 URL 설정

**수정 파일:** `lib/core/constants/api_constants.dart`

**변경 전:**
```dart
static const String localBaseUrl = 'http://localhost:8080';
```

**변경 후:**
```dart
static const String localBaseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터용
```

**플랫폼별 URL:**
- Android 에뮬레이터: `http://10.0.2.2:8080`
- iOS 시뮬레이터: `http://localhost:8080`
- 실제 기기: `http://192.168.x.x:8080` (Mac의 실제 IP)

## 🎯 SockJS vs 순수 WebSocket

### SockJS (현재 사용)
```dart
StompConfig.sockJS(
  url: 'http://localhost:8080/ws/chat',
  // ...
)
```

**특징:**
- HTTP URL 사용 (`http://` 또는 `https://`)
- 자동으로 WebSocket 업그레이드 시도
- WebSocket 지원 안되면 폴링 등 대체 방법 사용
- 브라우저 호환성 좋음

### 순수 WebSocket
```dart
StompConfig(
  url: 'ws://localhost:8080/ws/chat',
  // ...
)
```

**특징:**
- WebSocket URL 사용 (`ws://` 또는 `wss://`)
- 순수 WebSocket 프로토콜만 사용
- WebSocket 지원 필수
- 더 빠르고 가벼움

## 🧪 테스트 방법

### 1. 서버 확인
```bash
# 서버가 실행 중인지 확인
curl http://localhost:8080/api/auth/login

# WebSocket 엔드포인트 확인
curl http://localhost:8080/ws/chat/info
```

### 2. Android 에뮬레이터에서 테스트
```bash
# 에뮬레이터에서 호스트 머신 접근 확인
adb shell
ping 10.0.2.2
```

### 3. 앱에서 테스트
1. 앱 실행 및 로그인
2. 채팅방 입장
3. AppBar에서 "온라인" 상태 확인
4. 메시지 전송 테스트

## 📝 플랫폼별 설정

### Android 에뮬레이터
```dart
static const String localBaseUrl = 'http://10.0.2.2:8080';
```

### iOS 시뮬레이터
```dart
static const String localBaseUrl = 'http://localhost:8080';
```

### 실제 기기 (Mac)
```bash
# Mac의 IP 주소 확인
ifconfig | grep "inet "
# 예: 192.168.45.80
```

```dart
static const String localBaseUrl = 'http://192.168.45.80:8080';
```

## 🔍 디버깅 팁

### 1. 연결 로그 확인
```dart
// websocket_data_source_impl.dart
@override
Future<void> connect(String accessToken) async {
  debugPrint('🔌 Connecting to: ${ApiConstants.baseUrl}/ws/chat');
  debugPrint('🔑 Token: ${accessToken.substring(0, 20)}...');
  
  // ... 연결 코드
  
  _stompClient!.activate();
  debugPrint('✅ WebSocket activated');
  return completer.future;
}
```

### 2. 에러 로그 확인
```dart
onWebSocketError: (dynamic error) {
  debugPrint('❌ WebSocket error: $error');
  _connectionStateController.add(false);
  if (!completer.isCompleted) {
    completer.completeError(error);
  }
},
```

### 3. 서버 로그 확인
```bash
# Spring Boot 서버 로그에서 WebSocket 연결 확인
# "WebSocket connection established" 메시지 확인
```

## ⚠️ 주의사항

### 1. CORS 설정 (서버)
서버에서 WebSocket CORS 설정 필요:
```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws/chat")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}
```

### 2. 방화벽 설정
- 로컬 개발 시 방화벽에서 8080 포트 허용
- 실제 기기 테스트 시 Mac과 기기가 같은 네트워크에 있어야 함

### 3. HTTPS/WSS (프로덕션)
프로덕션 환경에서는 HTTPS/WSS 사용:
```dart
static const String devBaseUrl = 'https://your-server.com';
// SockJS가 자동으로 WSS로 업그레이드
```

## 🚀 배포 전 체크리스트

- [x] SockJS 설정 (`StompConfig.sockJS()`)
- [x] Android 에뮬레이터용 URL (`10.0.2.2`)
- [x] HTTP URL 사용 (SockJS가 자동 업그레이드)
- [x] 서버 WebSocket 엔드포인트 확인
- [x] CORS 설정 확인
- [x] 연결 테스트 성공

## 🎉 결과

이제 다음과 같이 작동합니다:

1. ✅ SockJS를 통한 WebSocket 연결
2. ✅ Android 에뮬레이터에서 정상 연결 (`10.0.2.2`)
3. ✅ HTTP 400 에러 해결
4. ✅ WebSocket 업그레이드 성공
5. ✅ 실시간 메시지 송수신 가능

**WebSocket 연결 문제가 완전히 해결되었습니다!** 🎉

## 📚 참고 자료

- [stomp_dart_client 문서](https://pub.dev/packages/stomp_dart_client)
- [SockJS 프로토콜](https://github.com/sockjs/sockjs-protocol)
- [Android 에뮬레이터 네트워킹](https://developer.android.com/studio/run/emulator-networking)
