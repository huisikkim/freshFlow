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
                  padding: const EdgeInsets.all(16),
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
                    
                    // 현재 사용자 ID와 비교
                    final authProvider = context.read<AuthProvider>();
                    final currentUserId = authProvider.user?.userType == 'STORE_OWNER'
                        ? widget.room.storeId
                        : widget.room.distributorId;
                    final isMe = message.senderId == currentUserId;

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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
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
