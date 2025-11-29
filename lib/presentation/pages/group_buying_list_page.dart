import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/group_buying_provider.dart';
import '../../domain/entities/group_buying_room.dart';
import 'group_buying_detail_page.dart';

class GroupBuyingListPage extends StatefulWidget {
  const GroupBuyingListPage({super.key});

  @override
  State<GroupBuyingListPage> createState() => _GroupBuyingListPageState();
}

class _GroupBuyingListPageState extends State<GroupBuyingListPage> {
  final NumberFormat currencyFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBuyingProvider>().fetchOpenRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark 
            ? const Color(0xFF111827).withOpacity(0.8)
            : const Color(0xFFF8FAFC).withOpacity(0.8),
        elevation: 0,
        title: Text(
          '공동구매',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
            onPressed: () {
              context.read<GroupBuyingProvider>().fetchOpenRooms();
            },
          ),
        ],
      ),
      body: Consumer<GroupBuyingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchOpenRooms();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.openRooms.isEmpty) {
            return const Center(
              child: Text('진행 중인 공동구매가 없습니다'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOpenRooms(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.openRooms.length,
              itemBuilder: (context, index) {
                final room = provider.openRooms[index];
                return _buildRoomCard(context, room);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, GroupBuyingRoom room) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupBuyingDetailPage(roomId: room.roomId),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 섹션 - 제목과 가격
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목과 추천 배지
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.productName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFB923C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  room.roomTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (room.featured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFB923C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '추천',
                                style: TextStyle(
                                  color: Color(0xFFFB923C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 가격 정보
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${room.discountRate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currencyFormat.format(room.originalPrice)}원',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currencyFormat.format(room.discountedPrice)}원',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 하단 섹션 - 진행 상황
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF1F2937).withOpacity(0.5)
                        : const Color(0xFFF8FAFC),
                  ),
                  child: Column(
                    children: [
                      // 진행률 바
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '달성률 ${room.achievementRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF22C55E),
                                ),
                              ),
                              Text(
                                '${room.currentQuantity}/${room.targetQuantity}개',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: room.achievementRate / 100,
                              minHeight: 10,
                              backgroundColor: isDark 
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 구분선
                      Divider(
                        height: 1,
                        color: isDark 
                            ? const Color(0xFF374151)
                            : const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 12),
                      // 참여자 및 시간 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 18,
                                color: isDark 
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${room.currentParticipants}명 참여',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark 
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          if (room.remainingMinutes != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 18,
                                  color: isDark 
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatRemainingTime(room.remainingMinutes!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark 
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  String _formatRemainingTime(int minutes) {
    if (minutes < 60) {
      return '$minutes분 남음';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours시간 남음';
    } else {
      final days = minutes ~/ 1440;
      return '$days일 남음';
    }
  }
}
