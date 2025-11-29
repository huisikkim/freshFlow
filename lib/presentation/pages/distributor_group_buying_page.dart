import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/distributor_group_buying_provider.dart';
import '../../domain/entities/group_buying_room.dart';
import 'create_group_buying_room_page.dart';

class DistributorGroupBuyingPage extends StatefulWidget {
  final String distributorId;
  final String distributorName;

  const DistributorGroupBuyingPage({
    super.key,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<DistributorGroupBuyingPage> createState() =>
      _DistributorGroupBuyingPageState();
}

class _DistributorGroupBuyingPageState
    extends State<DistributorGroupBuyingPage> {
  final NumberFormat currencyFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DistributorGroupBuyingProvider>()
          .fetchMyRooms(widget.distributorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 공동구매 방'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<DistributorGroupBuyingProvider>()
                  .fetchMyRooms(widget.distributorId);
            },
          ),
        ],
      ),
      body: Consumer<DistributorGroupBuyingProvider>(
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
                      provider.fetchMyRooms(widget.distributorId);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.myRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('생성한 공동구매 방이 없습니다'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateRoom(context),
                    icon: const Icon(Icons.add),
                    label: const Text('공동구매 방 만들기'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyRooms(widget.distributorId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myRooms.length,
              itemBuilder: (context, index) {
                final room = provider.myRooms[index];
                return _buildRoomCard(context, room);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRoom(context),
        icon: const Icon(Icons.add),
        label: const Text('방 만들기'),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, GroupBuyingRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                _buildStatusChip(room.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              room.productName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Room ID: ${room.roomId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
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
            if (room.status == RoomStatus.waiting) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openRoom(context, room),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('방 오픈하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(RoomStatus status) {
    Color color;
    String text;

    switch (status) {
      case RoomStatus.waiting:
        color = Colors.grey;
        text = '대기중';
        break;
      case RoomStatus.open:
        color = Colors.green;
        text = '오픈';
        break;
      case RoomStatus.closedSuccess:
        color = Colors.blue;
        text = '마감성공';
        break;
      case RoomStatus.closedFailed:
        color = Colors.red;
        text = '마감실패';
        break;
      case RoomStatus.orderCreated:
        color = Colors.orange;
        text = '주문생성';
        break;
      case RoomStatus.completed:
        color = Colors.purple;
        text = '완료';
        break;
      case RoomStatus.cancelled:
        color = Colors.red;
        text = '취소';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

  void _navigateToCreateRoom(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupBuyingRoomPage(
          distributorId: widget.distributorId,
          distributorName: widget.distributorName,
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      context
          .read<DistributorGroupBuyingProvider>()
          .fetchMyRooms(widget.distributorId);
    }
  }

  void _openRoom(BuildContext context, GroupBuyingRoom room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방 오픈'),
        content: Text('${room.roomTitle} 방을 오픈하시겠습니까?\n오픈 후 가게들이 참여할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('오픈'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final provider = context.read<DistributorGroupBuyingProvider>();
    final success = await provider.openGroupBuyingRoom(
      roomId: room.roomId,
      distributorId: widget.distributorId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방이 오픈되었습니다!')),
      );
      provider.fetchMyRooms(widget.distributorId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '방 오픈에 실패했습니다')),
      );
    }
  }
}
