import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/settlement_provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// 가게사장님용 정산 페이지
class StoreSettlementPage extends StatefulWidget {
  const StoreSettlementPage({Key? key}) : super(key: key);

  @override
  State<StoreSettlementPage> createState() => _StoreSettlementPageState();
}

class _SettlementColors {
  static const primary = Color(0xFFD4AF37); // Gold
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  static const teal = Color(0xFF14B8A6);
  
  static const cardBg = Color(0xFF1F2937);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const divider = Color(0xFF374151);
  static const background = Color(0xFF111827);
}

class _StoreSettlementPageState extends State<StoreSettlementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 이번 달 기본값 설정
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final settlementProvider = context.read<SettlementProvider>();
    
    if (authProvider.user?.storeId == null) {
      return;
    }

    final storeId = authProvider.user!.storeId!;

    // 통계 조회
    settlementProvider.fetchStoreStatistics(storeId, startDate: _startDate, endDate: _endDate);
    
    // 일일 정산 조회
    settlementProvider.fetchStoreDailySettlements(storeId, startDate: _startDate, endDate: _endDate);
    
    // 개별 정산 조회
    settlementProvider.fetchStoreSettlements(storeId);
    
    // 총 미수금 조회
    settlementProvider.fetchTotalOutstanding(storeId);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettlementColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _SettlementColors.background,
        title: const Text(
          '정산 관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _SettlementColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: _SettlementColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              color: _SettlementColors.primary,
              onPressed: _selectDateRange,
              tooltip: '기간 선택',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: _SettlementColors.primary,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelColor: _SettlementColors.primary,
            unselectedLabelColor: _SettlementColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: '대시보드'),
              Tab(text: '일일 정산'),
              Tab(text: '개별 정산'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildDailySettlements(),
          _buildIndividualSettlements(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<SettlementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _SettlementColors.primary,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              '오류: ${provider.error}',
              style: const TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        final stats = provider.statistics;
        if (stats == null) {
          return const Center(
            child: Text(
              '통계 데이터가 없습니다',
              style: TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 기간 표시
                if (_startDate != null && _endDate != null)
                  Container(
                    decoration: BoxDecoration(
                      color: _SettlementColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _SettlementColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: _SettlementColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${DateFormat('yyyy-MM-dd').format(_startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _SettlementColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                
                // 총 매출액
                _buildStatCard(
                  '총 매출액',
                  stats.totalSalesAmount,
                  Colors.blue,
                  Icons.attach_money,
                ),
                const SizedBox(height: 12),
                
                // 지불 완료 금액
                _buildStatCard(
                  '지불 완료',
                  stats.totalPaidAmount,
                  Colors.green,
                  Icons.check_circle,
                ),
                const SizedBox(height: 12),
                
                // 미수금 (강조)
                _buildStatCard(
                  '미수금',
                  stats.totalOutstandingAmount,
                  Colors.red,
                  Icons.warning,
                ),
                const SizedBox(height: 12),
                
                // 결제율
                Container(
                  decoration: BoxDecoration(
                    color: _SettlementColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _SettlementColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: _SettlementColors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '결제율',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _SettlementColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stats.paymentRate / 100,
                          backgroundColor: _SettlementColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stats.paymentRate >= 80 ? _SettlementColors.green : 
                            stats.paymentRate >= 50 ? _SettlementColors.orange : _SettlementColors.red,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${stats.paymentRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _SettlementColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 주문 건수
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard(
                        '총 주문',
                        '${stats.totalOrderCount}건',
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        '카탈로그',
                        '${stats.catalogOrderCount}건',
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard(
                        '카탈로그 매출',
                        NumberFormat('#,###').format(stats.catalogSalesAmount) + '원',
                        Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        '식자재',
                        '${stats.ingredientOrderCount}건',
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailySettlements() {
    return Consumer<SettlementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _SettlementColors.primary,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              '오류: ${provider.error}',
              style: const TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        final dailySettlements = provider.dailySettlements;
        if (dailySettlements.isEmpty) {
          return const Center(
            child: Text(
              '일일 정산 내역이 없습니다',
              style: TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dailySettlements.length,
            itemBuilder: (context, index) {
              final settlement = dailySettlements[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _SettlementColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: _SettlementColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('yyyy-MM-dd').format(settlement.settlementDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _SettlementColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _SettlementColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${settlement.orderCount}건',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _SettlementColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDailyRow('매출액', settlement.totalSalesAmount, _SettlementColors.blue),
                    const SizedBox(height: 8),
                    _buildDailyRow('지불액', settlement.totalPaidAmount, _SettlementColors.green),
                    const SizedBox(height: 8),
                    _buildDailyRow('미수금', settlement.totalOutstandingAmount, _SettlementColors.red),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: settlement.paymentRate / 100,
                        backgroundColor: _SettlementColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          settlement.paymentRate >= 80 ? _SettlementColors.green : 
                          settlement.paymentRate >= 50 ? _SettlementColors.orange : _SettlementColors.red,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '결제율: ${settlement.paymentRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _SettlementColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildIndividualSettlements() {
    return Consumer<SettlementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _SettlementColors.primary,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              '오류: ${provider.error}',
              style: const TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        final settlements = provider.settlements;
        if (settlements.isEmpty) {
          return const Center(
            child: Text(
              '정산 내역이 없습니다',
              style: TextStyle(color: _SettlementColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              final isPending = settlement.status == 'PENDING';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _SettlementColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (isPending ? _SettlementColors.orange : _SettlementColors.green).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPending ? Icons.pending_outlined : Icons.check_circle_outline,
                              color: isPending ? _SettlementColors.orange : _SettlementColors.green,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '주문번호',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _SettlementColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  settlement.orderId,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _SettlementColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(settlement.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(settlement.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusTextColor(settlement.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSettlementDetailRow('정산 금액', settlement.settlementAmount),
                      const SizedBox(height: 8),
                      _buildSettlementDetailRow('미수금', settlement.outstandingAmount),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: _SettlementColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '정산일: ${DateFormat('yyyy-MM-dd HH:mm').format(settlement.settlementDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _SettlementColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (settlement.completedAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: _SettlementColors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '완료일: ${DateFormat('yyyy-MM-dd HH:mm').format(settlement.completedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _SettlementColors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int amount, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: _SettlementColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _SettlementColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _SettlementColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat('#,###').format(amount),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 2),
                      child: Text(
                        '원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: color,
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
    );
  }

  Widget _buildSmallStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: _SettlementColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _SettlementColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _SettlementColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value.replaceAll('원', '').replaceAll('건', ''),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 1),
                child: Text(
                  value.contains('원') ? '원' : '건',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(String label, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _SettlementColors.textSecondary,
          ),
        ),
        Text(
          '${NumberFormat('#,###').format(amount)}원',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '대기';
      case 'PROCESSING':
        return '처리중';
      case 'COMPLETED':
        return '완료';
      case 'FAILED':
        return '실패';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return _SettlementColors.orange.withOpacity(0.1);
      case 'PROCESSING':
        return _SettlementColors.blue.withOpacity(0.1);
      case 'COMPLETED':
        return _SettlementColors.green.withOpacity(0.1);
      case 'FAILED':
        return _SettlementColors.red.withOpacity(0.1);
      default:
        return _SettlementColors.divider;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'PENDING':
        return _SettlementColors.orange;
      case 'PROCESSING':
        return _SettlementColors.blue;
      case 'COMPLETED':
        return _SettlementColors.green;
      case 'FAILED':
        return _SettlementColors.red;
      default:
        return _SettlementColors.textSecondary;
    }
  }

  Widget _buildSettlementDetailRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _SettlementColors.textSecondary,
          ),
        ),
        Text(
          '${NumberFormat('#,###').format(amount)}원',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _SettlementColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
