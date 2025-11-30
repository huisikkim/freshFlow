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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 28,
            ),
            onPressed: () {
              // 검색 기능 구현 예정
            },
          ),
        ],
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
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '채팅 목록을 불러올 수 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '서버 연결을 확인해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
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
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '아직 대화가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadChatRooms(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.chatRooms.length,
              itemBuilder: (context, index) {
                final room = provider.chatRooms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChatRoomTile(
                    room: room,
                    onTap: () => _navigateToChatRoom(context, room),
                  ),
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

    // 마지막 메시지 시간 포맷
    final timeText = room.lastMessageAt != null 
        ? _formatDateTime(room.lastMessageAt!) 
        : '';

    // 읽지 않은 메시지가 있는지 확인
    final hasUnread = room.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 아바타
              _buildAvatar(displayName),
              const SizedBox(width: 12),
              // 채팅 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름과 시간
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF9FAFB),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeText.isNotEmpty)
                          Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 마지막 메시지와 읽지 않은 개수
                    Row(
                      children: [
                        // 읽음 표시 아이콘 (읽지 않은 메시지가 없을 때만)
                        if (!hasUnread && room.lastMessageAt != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.done_all,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _getLastMessagePreview(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // 읽지 않은 메시지 배지
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444), // red-500
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.unreadCount > 99 ? '99+' : room.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String displayName) {
    // 이름의 첫 글자로 색상 결정
    final colors = [
      const Color(0xFFEC4899), // pink
      const Color(0xFF3B82F6), // blue
      const Color(0xFF10B981), // green
      const Color(0xFFF59E0B), // amber
      const Color(0xFFEF4444), // red
      const Color(0xFF8B5CF6), // purple
    ];
    
    final colorIndex = displayName.codeUnitAt(0) % colors.length;
    final avatarColor = colors[colorIndex];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayName[0],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  String _getLastMessagePreview() {
    // 실제로는 room에서 마지막 메시지를 가져와야 하지만,
    // 현재 ChatRoom 엔티티에 lastMessage 필드가 없으므로 임시 텍스트 사용
    if (room.lastMessageAt == null) {
      return '대화를 시작해보세요';
    }
    return '메시지를 확인하세요';
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
