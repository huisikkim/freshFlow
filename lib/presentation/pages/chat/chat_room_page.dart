import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/chat_room.dart';
import '../../providers/chat_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.loadMessages(widget.room.roomId, refresh: true);
      provider.enterRoom(widget.room.roomId);

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
    // TODO: userType에 따라 표시할 이름 결정
    final displayName = widget.room.distributorName; // 또는 widget.room.storeName

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
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
                    // TODO: 현재 사용자 ID와 비교
                    final isMe = false; // message.senderId == currentUserId

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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendTextMessage(
          roomId: widget.room.roomId,
          content: text,
        );

    _messageController.clear();
  }
}
