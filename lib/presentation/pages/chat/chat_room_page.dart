import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/chat_room.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';

/// 채팅방 페이지
/// Single Responsibility: 채팅방 UI만 담당
class ChatRoomPage extends StatefulWidget {
  final ChatRoom room;

  const ChatRoomPage({
    super.key,
    required this.room,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = context.read<ChatProvider>();
      final authProvider = context.read<AuthProvider>();
      final accessToken = authProvider.user?.accessToken ?? '';
      
      print('=== 채팅방 입장 ===');
      print('로그인 사용자: ${authProvider.user?.username}');
      print('사용자 타입: ${authProvider.user?.userType}');
      print('storeId: ${authProvider.user?.storeId}');
      print('distributorId: ${authProvider.user?.distributorId}');
      print('채팅방 ID: ${widget.room.roomId}');
      print('==================\n');
      
      // 메시지 로딩 (에러가 있어도 기존 메시지는 표시)
      await chatProvider.loadMessages(widget.room.roomId, refresh: true);
      
      // WebSocket 연결 시도
      await chatProvider.enterRoom(widget.room.roomId, accessToken);

      // WebSocket 연결 에러가 있으면 SnackBar 표시하고 즉시 에러 클리어
      if (mounted && chatProvider.error != null) {
        final errorMessage = chatProvider.error!;
        chatProvider.clearError(); // 즉시 에러 클리어하여 화면에 표시되지 않도록
        
        if (errorMessage.contains('채팅 서버') || errorMessage.contains('WebSocket')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('채팅 서버에 연결할 수 없습니다\n이전 메시지는 확인할 수 있습니다'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '재시도',
                textColor: Colors.white,
                onPressed: () async {
                  await chatProvider.enterRoom(widget.room.roomId, accessToken);
                  if (mounted && chatProvider.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('채팅 서버에 연결되었습니다'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted && chatProvider.error != null) {
                    chatProvider.clearError();
                  }
                },
              ),
            ),
          );
        }
      }

      // 스크롤 리스너 (무한 스크롤)
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    
    // 타이핑 중단 이벤트 전송
    if (_isTyping) {
      context.read<ChatProvider>().sendTypingEvent(
        roomId: widget.room.roomId,
        isTyping: false,
      );
    }
    
    context.read<ChatProvider>().leaveRoom(widget.room.roomId);
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text.trim();
    final chatProvider = context.read<ChatProvider>();

    if (text.isNotEmpty) {
      // 타이핑 시작
      if (!_isTyping) {
        _isTyping = true;
        chatProvider.sendTypingEvent(
          roomId: widget.room.roomId,
          isTyping: true,
        );
      }

      // 기존 타이머 취소
      _typingTimer?.cancel();

      // 2초 후 타이핑 중단
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          chatProvider.sendTypingEvent(
            roomId: widget.room.roomId,
            isTyping: false,
          );
        }
      });
    } else {
      // 텍스트가 비어있으면 타이핑 중단
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        chatProvider.sendTypingEvent(
          roomId: widget.room.roomId,
          isTyping: false,
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      // 스크롤 상단 도달 - 이전 메시지 로드
      final provider = context.read<ChatProvider>();
      if (!provider.isLoading && provider.hasMoreMessages) {
        provider.loadMessages(widget.room.roomId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userType = authProvider.user?.userType;
    
    // userType에 따라 표시할 이름 결정
    final displayName = userType == 'STORE_OWNER'
        ? widget.room.distributorName
        : widget.room.storeName;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFFE5E5E7),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: provider.isConnected 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFF6B7280),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      provider.isConnected ? '온라인' : '오프라인',
                      style: TextStyle(
                        fontSize: 12,
                        color: provider.isConnected 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF98989D),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {},
            color: const Color(0xFFE5E5E7),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFF3A3A3C),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // WebSocket 연결 에러는 화면에 표시하지 않음 (SnackBar로만 처리)
                // 메시지가 없고 WebSocket 에러가 아닌 경우에만 에러 화면 표시
                if (provider.error != null && 
                    provider.messages.isEmpty && 
                    !provider.error!.contains('채팅 서버') &&
                    !provider.error!.contains('WebSocket')) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '메시지를 불러올 수 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadMessages(
                              widget.room.roomId,
                              refresh: true,
                            );
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text('메시지가 없습니다\n첫 메시지를 보내보세요!'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: provider.messages.length +
                            (provider.hasMoreMessages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length) {
                            // 로딩 인디케이터
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final message =
                              provider.messages[provider.messages.length - 1 - index];
                          
                          // 현재 사용자 ID와 비교 (로그인한 사용자의 ID 사용)
                          final authProvider = context.read<AuthProvider>();
                          final currentUserId = authProvider.user?.userType == 'STORE_OWNER'
                              ? authProvider.user?.storeId
                              : authProvider.user?.distributorId;
                          final isMe = message.senderId == currentUserId;

                          // 디버깅 로그
                          print('=== 메시지 정렬 디버그 ===');
                          print('메시지 ID: ${message.id}');
                          print('메시지 내용: ${message.content}');
                          print('발신자 ID (senderId): ${message.senderId}');
                          print('발신자 타입 (senderType): ${message.senderType}');
                          print('현재 사용자 타입: ${authProvider.user?.userType}');
                          print('현재 로그인 사용자 username: ${authProvider.user?.username}');
                          print('현재 로그인 사용자 storeId: ${authProvider.user?.storeId}');
                          print('현재 로그인 사용자 distributorId: ${authProvider.user?.distributorId}');
                          print('현재 사용자 ID (currentUserId): $currentUserId');
                          print('채팅방 storeId: ${widget.room.storeId}');
                          print('채팅방 distributorId: ${widget.room.distributorId}');
                          print('isMe 판단 결과: $isMe (${message.senderId} == $currentUserId)');
                          print('========================\n');

                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
                    ),
                    // 타이핑 인디케이터
                    if (provider.isOtherUserTyping)
                      TypingIndicator(
                        userName: provider.typingUserName,
                      ),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          border: Border(
            top: BorderSide(
              color: Color(0xFF3A3A3C),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () {},
                color: const Color(0xFFE5E5E7),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: '메시지를 입력하세요',
                          hintStyle: TextStyle(
                            color: Color(0xFF98989D),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFE5E5E7),
                        ),
                        maxLines: null,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied, size: 20),
                      onPressed: () {},
                      color: const Color(0xFF98989D),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: IconButton(
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: _sendMessage,
                  color: Colors.black,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    
    // 메시지 전송 시 타이핑 중단
    if (_isTyping) {
      _isTyping = false;
      _typingTimer?.cancel();
      chatProvider.sendTypingEvent(
        roomId: widget.room.roomId,
        isTyping: false,
      );
    }
    
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
}
