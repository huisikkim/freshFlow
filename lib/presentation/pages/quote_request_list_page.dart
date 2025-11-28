import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/quote_request_provider.dart';
import 'package:fresh_flow/domain/entities/quote_request.dart';
import 'package:fresh_flow/presentation/pages/quote_request_detail_page.dart';
import 'package:fresh_flow/injection_container.dart';

class QuoteRequestListPage extends StatefulWidget {
  final bool isDistributor;

  const QuoteRequestListPage({
    super.key,
    this.isDistributor = false,
  });

  @override
  State<QuoteRequestListPage> createState() => _QuoteRequestListPageState();
}

class _QuoteRequestListPageState extends State<QuoteRequestListPage> {
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuoteRequests();
    });
  }

  void _loadQuoteRequests() {
    final provider = context.read<QuoteRequestProvider>();
    if (widget.isDistributor) {
      provider.loadDistributorQuoteRequests();
    } else {
      provider.loadStoreQuoteRequests();
    }
  }

  List<QuoteRequest> _filterQuoteRequests(List<QuoteRequest> requests) {
    if (_selectedStatus == 'ALL') return requests;
    return requests.where((r) => r.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.isDistributor ? '받은 견적 요청' : '내 견적 요청',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            color: const Color(0xFF6B7280),
            onPressed: _loadQuoteRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Consumer<QuoteRequestProvider>(
              builder: (context, provider, child) {
                if (provider.state == QuoteRequestState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6F61),
                    ),
                  );
                }

                if (provider.state == QuoteRequestState.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ?? '조회 실패',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadQuoteRequests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F61),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredRequests =
                    _filterQuoteRequests(provider.quoteRequests);

                if (filteredRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Color(0xFFA9B4C2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'ALL'
                              ? '견적 요청이 없습니다'
                              : '${_getStatusText(_selectedStatus)} 견적이 없습니다',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D405B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadQuoteRequests(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      return _buildQuoteRequestCard(filteredRequests[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('ALL', '전체'),
            const SizedBox(width: 8),
            _buildFilterChip('PENDING', '대기중'),
            const SizedBox(width: 8),
            _buildFilterChip('ACCEPTED', '수락됨'),
            const SizedBox(width: 8),
            _buildFilterChip('REJECTED', '거절됨'),
            const SizedBox(width: 8),
            _buildFilterChip('COMPLETED', '완료'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFCE8E7)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: Color(0xFFD04038),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFD04038)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteRequestCard(QuoteRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => InjectionContainer.getQuoteRequestProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => InjectionContainer.getChatProvider(),
                  ),
                ],
                child: QuoteRequestDetailPage(
                  quoteRequest: request,
                  isDistributor: widget.isDistributor,
                ),
              ),
            ),
          ).then((_) => _loadQuoteRequests());
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.isDistributor
                          ? request.storeName
                          : request.distributorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.requestedProducts,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              if (request.message != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.message!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(request.requestedAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              if (request.estimatedAmount != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '예상 금액: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${_formatNumber(request.estimatedAmount!)}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
        return const Color(0xFFFB923C); // orange-400
      case 'ACCEPTED':
        return const Color(0xFF10B981); // green-500
      case 'REJECTED':
        return const Color(0xFFEF4444); // red-500
      case 'COMPLETED':
        return const Color(0xFF3B82F6); // blue-500
      default:
        return const Color(0xFF9CA3AF); // gray-400
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
