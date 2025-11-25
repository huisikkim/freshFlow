import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/domain/entities/quote_request.dart';

class QuoteRequestDetailPage extends StatefulWidget {
  final QuoteRequest quoteRequest;
  final bool isDistributor;

  const QuoteRequestDetailPage({
    super.key,
    required this.quoteRequest,
    this.isDistributor = false,
  });

  @override
  State<QuoteRequestDetailPage> createState() => _QuoteRequestDetailPageState();
}

class _QuoteRequestDetailPageState extends State<QuoteRequestDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: const Text('견적 요청 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            if (widget.quoteRequest.distributorResponse != null)
              _buildResponseCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.quoteRequest.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(widget.quoteRequest.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isDistributor
                  ? widget.quoteRequest.storeName
                  : widget.quoteRequest.distributorName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D405B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '요청 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D405B),
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.inventory_2,
              '요청 품목',
              widget.quoteRequest.requestedProducts,
            ),
            if (widget.quoteRequest.message != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.message,
                '추가 요청사항',
                widget.quoteRequest.message!,
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              '요청 시간',
              _formatDateTime(widget.quoteRequest.requestedAt),
            ),
            if (widget.quoteRequest.estimatedAmount != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.attach_money,
                '예상 금액',
                '${_formatNumber(widget.quoteRequest.estimatedAmount!)}원',
                valueColor: const Color(0xFF06D6A0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      elevation: 2,
      color: const Color(0xFFF0F9FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.reply,
                  color: Color(0xFF06D6A0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '유통업체 응답',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D405B),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              widget.quoteRequest.distributorResponse!,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF3D405B),
                height: 1.5,
              ),
            ),
            if (widget.quoteRequest.respondedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                '응답 시간: ${_formatDateTime(widget.quoteRequest.respondedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA9B4C2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = widget.quoteRequest.status;

    if (widget.isDistributor && status == 'PENDING') {
      return _buildDistributorActions();
    } else if (!widget.isDistributor) {
      if (status == 'PENDING') {
        return _buildCancelButton();
      } else if (status == 'ACCEPTED') {
        return _buildCompleteButton();
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDistributorActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showRespondDialog(true),
          icon: const Icon(Icons.check_circle),
          label: const Text('수락하기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06D6A0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showRespondDialog(false),
          icon: const Icon(Icons.cancel),
          label: const Text('거절하기'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _handleCancel,
      icon: const Icon(Icons.cancel),
      label: const Text('견적 요청 취소'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return ElevatedButton.icon(
      onPressed: _handleComplete,
      icon: const Icon(Icons.check_circle),
      label: const Text('완료 처리'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06D6A0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showRespondDialog(bool isAccept) {
    final responseController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAccept ? '견적 수락' : '견적 거절'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAccept) ...[
                const Text(
                  '예상 금액 (원)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '예: 500000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                '응답 메시지',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: responseController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: isAccept
                      ? '예: 매주 월요일 오전 8시 배송 가능합니다.'
                      : '예: 죄송합니다. 현재 재고가 부족합니다.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('응답 메시지를 입력해주세요')),
                );
                return;
              }

              final provider = context.read<QuoteRequestProvider>();
              await provider.respondToQuoteRequest(
                quoteId: widget.quoteRequest.id,
                status: isAccept ? 'ACCEPTED' : 'REJECTED',
                estimatedAmount: isAccept && amountController.text.isNotEmpty
                    ? int.tryParse(amountController.text)
                    : null,
                response: responseController.text,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                if (provider.state == QuoteRequestState.success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAccept ? '견적을 수락했습니다' : '견적을 거절했습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? '응답 실패'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAccept ? const Color(0xFF06D6A0) : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isAccept ? '수락' : '거절'),
          ),
        ],
      ),
    );
  }

  void _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('견적 요청 취소'),
        content: const Text('정말 견적 요청을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('예, 취소합니다'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<QuoteRequestProvider>();
      await provider.cancelQuoteRequest(widget.quoteRequest.id);

      if (mounted) {
        if (provider.state == QuoteRequestState.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('견적 요청이 취소되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? '취소 실패'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('완료 처리'),
        content: const Text('이 견적을 완료 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06D6A0),
              foregroundColor: Colors.white,
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<QuoteRequestProvider>();
      await provider.completeQuoteRequest(widget.quoteRequest.id);

      if (mounted) {
        if (provider.state == QuoteRequestState.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('견적이 완료 처리되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? '완료 처리 실패'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFA9B4C2)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA9B4C2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? const Color(0xFF3D405B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '대기중';
      case 'ACCEPTED':
        return '수락됨';
      case 'REJECTED':
        return '거절됨';
      case 'COMPLETED':
        return '완료됨';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
