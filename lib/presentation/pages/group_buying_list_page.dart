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
    return Scaffold(
      appBar: AppBar(
        title: const Text('공동구매'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupBuyingDetailPage(roomId: room.roomId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.roomTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (room.featured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '추천',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                room.productName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${currencyFormat.format(room.originalPrice)}원',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currencyFormat.format(room.discountedPrice)}원',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${room.discountRate.toStringAsFixed(0)}% 할인',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: room.achievementRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '달성률: ${room.achievementRate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${room.currentQuantity}/${room.targetQuantity}개',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text('${room.currentParticipants}명 참여'),
                    ],
                  ),
                  if (room.remainingMinutes != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(_formatRemainingTime(room.remainingMinutes!)),
                      ],
                    ),
                ],
              ),
            ],
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
