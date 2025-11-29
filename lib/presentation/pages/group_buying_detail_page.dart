import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/group_buying_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/group_buying_room.dart';

class GroupBuyingDetailPage extends StatefulWidget {
  final String roomId;

  const GroupBuyingDetailPage({super.key, required this.roomId});

  @override
  State<GroupBuyingDetailPage> createState() => _GroupBuyingDetailPageState();
}

class _GroupBuyingDetailPageState extends State<GroupBuyingDetailPage> {
  final NumberFormat currencyFormat = NumberFormat('#,###');
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBuyingProvider>().fetchRoomDetail(widget.roomId);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공동구매 상세'),
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
                      provider.fetchRoomDetail(widget.roomId);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final room = provider.selectedRoom;
          if (room == null) {
            return const Center(child: Text('방 정보를 불러올 수 없습니다'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(room),
                _buildPriceInfo(room),
                _buildProgressInfo(room),
                _buildDetailInfo(room),
                _buildJoinForm(context, room),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(GroupBuyingRoom room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (room.featured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '추천',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            room.roomTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            room.productName,
            style: const TextStyle(fontSize: 18),
          ),
          if (room.category != null) ...[
            const SizedBox(height: 4),
            Text(
              '카테고리: ${room.category}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInfo(GroupBuyingRoom room) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가격 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '정가: ${currencyFormat.format(room.originalPrice)}원',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '할인가: ${currencyFormat.format(room.discountedPrice)}원',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${room.discountRate.toStringAsFixed(0)}% 할인',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '개당 ${currencyFormat.format(room.savingsPerUnit)}원 절약',
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(GroupBuyingRoom room) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '진행 현황',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: room.achievementRate / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '달성률: ${room.achievementRate.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${room.currentQuantity}/${room.targetQuantity}개',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                Icons.people,
                '${room.currentParticipants}명 참여',
              ),
              if (room.remainingMinutes != null)
                _buildInfoChip(
                  Icons.access_time,
                  _formatRemainingTime(room.remainingMinutes!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(GroupBuyingRoom room) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상세 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('유통업자', room.distributorName),
          _buildInfoRow('지역', room.region),
          _buildInfoRow('최소 주문', '${room.minOrderPerStore}개'),
          if (room.maxOrderPerStore != null)
            _buildInfoRow('최대 주문', '${room.maxOrderPerStore}개'),
          _buildInfoRow('최소 참여자', '${room.minParticipants}명'),
          if (room.deliveryFeePerStore != null)
            _buildInfoRow(
              '배송비',
              '${currencyFormat.format(room.deliveryFeePerStore)}원',
            ),
          if (room.description != null) ...[
            const SizedBox(height: 12),
            const Text(
              '설명',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(room.description!),
          ],
          if (room.specialNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(child: Text(room.specialNote!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinForm(BuildContext context, GroupBuyingRoom room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '참여하기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '수량',
              hintText: '${room.minOrderPerStore} ~ ${room.maxOrderPerStore ?? "제한없음"}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: '배송 주소 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '연락처 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _requestController,
            decoration: const InputDecoration(
              labelText: '배송 요청사항 (선택)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _handleJoin(context, room),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '참여하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(text),
        ],
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

  void _handleJoin(BuildContext context, GroupBuyingRoom room) async {
    final quantity = int.tryParse(_quantityController.text);
    
    if (quantity == null || quantity < room.minOrderPerStore) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 ${room.minOrderPerStore}개 이상 주문해야 합니다')),
      );
      return;
    }

    if (room.maxOrderPerStore != null && quantity > room.maxOrderPerStore!) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 ${room.maxOrderPerStore}개까지 주문 가능합니다')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final storeId = authProvider.user?.storeId;

    if (storeId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보를 찾을 수 없습니다')),
      );
      return;
    }

    final provider = context.read<GroupBuyingProvider>();
    final success = await provider.joinGroupBuying(
      roomId: room.roomId,
      storeId: storeId,
      quantity: quantity,
      deliveryAddress: _addressController.text.isEmpty ? null : _addressController.text,
      deliveryPhone: _phoneController.text.isEmpty ? null : _phoneController.text,
      deliveryRequest: _requestController.text.isEmpty ? null : _requestController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공동구매 참여가 완료되었습니다!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '참여에 실패했습니다')),
      );
    }
  }
}
