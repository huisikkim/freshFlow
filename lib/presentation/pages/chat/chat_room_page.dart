import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/chat_room.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/message_bubble.dart';

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

  @override
  void initState() {
    super.initState();
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
      
      chatProvider.loadMessages(widget.room.roomId, refresh: true);
      await chatProvider.enterRoom(widget.room.roomId, accessToken);

      // 스크롤 리스너 (무한 스크롤)
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().leaveRoom(widget.room.roomId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF1A1A1A),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.isConnected 
                            ? const Color(0xFF10B981) 
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isConnected ? '온라인' : '오프라인',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: provider.isConnected 
                        ? const Color(0xFF10B981) 
                        : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {},
            color: const Color(0xFF1A1A1A),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.withOpacity(0.1),
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

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadMessages(
                            widget.room.roomId,
                            refresh: true,
                          ),
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

                return ListView.builder(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            onPressed: () {},
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_outlined, size: 22),
                    onPressed: () {},
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 20),
              onPressed: _sendMessage,
              color: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

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
}
