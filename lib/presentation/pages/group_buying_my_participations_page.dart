import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/group_buying_provider.dart';
import '../../domain/entities/group_buying_participant.dart';

class GroupBuyingMyParticipationsPage extends StatefulWidget {
  final String storeId;

  const GroupBuyingMyParticipationsPage({
    super.key,
    required this.storeId,
  });

  @override
  State<GroupBuyingMyParticipationsPage> createState() =>
      _GroupBuyingMyParticipationsPageState();
}

class _GroupBuyingMyParticipationsPageState
    extends State<GroupBuyingMyParticipationsPage> {
  final NumberFormat currencyFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBuyingProvider>().fetchMyParticipations(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 참여 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<GroupBuyingProvider>()
                  .fetchMyParticipations(widget.storeId);
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
                      provider.fetchMyParticipations(widget.storeId);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.myParticipations.isEmpty) {
            return const Center(
              child: Text('참여한 공동구매가 없습니다'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyParticipations(widget.storeId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myParticipations.length,
              itemBuilder: (context, index) {
                final participation = provider.myParticipations[index];
                return _buildParticipationCard(participation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipationCard(GroupBuyingParticipant participation) {
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
                Text(
                  participation.storeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(participation.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('수량', '${participation.quantity}개'),
            _buildInfoRow(
              '단가',
              '${currencyFormat.format(participation.unitPrice)}원',
            ),
            _buildInfoRow(
              '상품 금액',
              '${currencyFormat.format(participation.totalProductAmount)}원',
            ),
            _buildInfoRow(
              '배송비',
              '${currencyFormat.format(participation.deliveryFee)}원',
            ),
            const Divider(),
            _buildInfoRow(
              '총 금액',
              '${currencyFormat.format(participation.totalAmount)}원',
              isTotal: true,
            ),
            _buildInfoRow(
              '절약 금액',
              '${currencyFormat.format(participation.savingsAmount)}원',
              isSavings: true,
            ),
            const SizedBox(height: 8),
            Text(
              '참여일: ${DateFormat('yyyy-MM-dd HH:mm').format(participation.joinedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (participation.deliveryAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                '배송지: ${participation.deliveryAddress}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isTotal = false, bool isSavings = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isSavings ? Colors.green : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isSavings ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ParticipantStatus status) {
    Color color;
    String text;

    switch (status) {
      case ParticipantStatus.joined:
        color = Colors.blue;
        text = '참여중';
        break;
      case ParticipantStatus.confirmed:
        color = Colors.green;
        text = '확정';
        break;
      case ParticipantStatus.orderCreated:
        color = Colors.orange;
        text = '주문생성';
        break;
      case ParticipantStatus.delivered:
        color = Colors.purple;
        text = '배송완료';
        break;
      case ParticipantStatus.cancelled:
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
}
