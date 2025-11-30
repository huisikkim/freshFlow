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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          '내 참여 내역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFD4AF37),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: const Color(0xFFD4AF37),
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
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchMyParticipations(widget.storeId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF1F2937),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (provider.myParticipations.isEmpty) {
            return const Center(
              child: Text(
                '참여한 공동구매가 없습니다',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
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
                    participation.storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF9FAFB),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
            const Divider(color: Color(0xFF374151)),
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            if (participation.deliveryAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                '배송지: ${participation.deliveryAddress}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFD1D5DB),
                ),
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
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isSavings ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isSavings ? const Color(0xFF22C55E) : (isTotal ? const Color(0xFFD4AF37) : const Color(0xFFE5E7EB)),
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
        color = const Color(0xFF3B82F6);
        text = '참여중';
        break;
      case ParticipantStatus.confirmed:
        color = const Color(0xFF22C55E);
        text = '확정';
        break;
      case ParticipantStatus.orderCreated:
        color = const Color(0xFFF59E0B);
        text = '주문생성';
        break;
      case ParticipantStatus.delivered:
        color = const Color(0xFF8B5CF6);
        text = '배송완료';
        break;
      case ParticipantStatus.cancelled:
        color = const Color(0xFFEF4444);
        text = '취소';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
