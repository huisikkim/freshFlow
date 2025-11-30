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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          widget.isDistributor ? '받은 견적 요청' : '내 견적 요청',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF9FAFB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(
          color: Color(0xFFD4AF37),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            color: const Color(0xFFD4AF37),
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
                      color: Color(0xFFD4AF37),
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
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ?? '조회 실패',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadQuoteRequests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF1F2937),
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
                          color: Color(0xFF4B5563),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'ALL'
                              ? '견적 요청이 없습니다'
                              : '${_getStatusText(_selectedStatus)} 견적이 없습니다',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFF111827),
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
              ? const Color(0xFFD4AF37)
              : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
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
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
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
        borderRadius: BorderRadius.circular(16),
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF9FAFB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(request.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontWeight: FontWeight.w700,
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
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.requestedProducts,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFD1D5DB),
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
                      size: 18,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.message!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
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
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(request.requestedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
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
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '예상 금액: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Text(
                        '${_formatNumber(request.estimatedAmount!)}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4AF37),
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
