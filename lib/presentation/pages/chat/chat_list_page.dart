import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/chat_room.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import 'chat_room_page.dart';

/// 채팅 목록 페이지
/// Single Responsibility: 채팅 목록 UI만 담당
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.chatRooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '채팅 목록을 불러올 수 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '서버 연결을 확인해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.clearError();
                      provider.loadChatRooms();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.chatRooms.isEmpty) {
            return const Center(
              child: Text('아직 대화가 없습니다'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadChatRooms(),
            child: ListView.separated(
              itemCount: provider.chatRooms.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = provider.chatRooms[index];
                return _ChatRoomTile(
                  room: room,
                  onTap: () => _navigateToChatRoom(context, room),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToChatRoom(BuildContext context, ChatRoom room) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(room: room),
      ),
    );
    
    // 채팅방에서 돌아왔을 때 목록 새로고침 (읽음 상태 반영)
    if (mounted) {
      context.read<ChatProvider>().loadChatRooms();
    }
  }
}

/// 채팅방 타일 위젯
/// Single Responsibility: 채팅방 항목 UI만 담당
class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userType = authProvider.user?.userType;
    
    // userType에 따라 표시할 이름 결정
    final displayName = userType == 'STORE_OWNER'
        ? room.distributorName
        : room.storeName;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(displayName[0]),
      ),
      title: Text(
        displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: room.lastMessageAt != null
          ? Text(
              _formatDateTime(room.lastMessageAt!),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: room.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                room.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}
