import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/settlement_provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// 유통업자용 정산 페이지
class DistributorSettlementPage extends StatefulWidget {
  const DistributorSettlementPage({Key? key}) : super(key: key);

  @override
  State<DistributorSettlementPage> createState() => _DistributorSettlementPageState();
}

class _SettlementColors {
  static const primary = Color(0xFF6366F1); // Indigo
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  static const teal = Color(0xFF14B8A6);
  
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const background = Color(0xFFF8FAFC);
}

class _DistributorSettlementPageState extends State<DistributorSettlementPage> with SingleTickerProviderStateMixin {
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
    
    if (authProvider.user?.distributorId == null) {
      return;
    }

    final distributorId = authProvider.user!.distributorId!;

    // 통계 조회
    settlementProvider.fetchDistributorStatistics(distributorId, startDate: _startDate, endDate: _endDate);
    
    // 일일 정산 조회
    settlementProvider.fetchDistributorDailySettlements(distributorId, startDate: _startDate, endDate: _endDate);
    
    // 개별 정산 조회
    settlementProvider.fetchDistributorSettlements(distributorId);
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
          color: _SettlementColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              color: _SettlementColors.textSecondary,
              onPressed: _selectDateRange,
              tooltip: '기간 선택',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _SettlementColors.divider, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: _SettlementColors.primary,
              indicatorWeight: 2,
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
                Tab(text: '정산 처리'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildDailySettlements(),
          _buildSettlementProcessing(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<SettlementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('오류: ${provider.error}'));
        }

        final stats = provider.statistics;
        if (stats == null) {
          return const Center(child: Text('통계 데이터가 없습니다'));
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('yyyy-MM-dd').format(_startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
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
                
                // 받을 금액 (미수금)
                _buildStatCard(
                  '받을 금액',
                  stats.totalOutstandingAmount,
                  Colors.orange,
                  Icons.account_balance_wallet,
                ),
                const SizedBox(height: 12),
                
                // 정산 완료 금액
                _buildStatCard(
                  '정산 완료',
                  stats.totalPaidAmount,
                  Colors.green,
                  Icons.check_circle,
                ),
                const SizedBox(height: 12),
                
                // 정산 완료율
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.purple),
                            const SizedBox(width: 8),
                            const Text(
                              '정산 완료율',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: stats.paymentRate / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stats.paymentRate >= 80 ? Colors.green : 
                            stats.paymentRate >= 50 ? Colors.orange : Colors.red,
                          ),
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.paymentRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('오류: ${provider.error}'));
        }

        final dailySettlements = provider.dailySettlements;
        if (dailySettlements.isEmpty) {
          return const Center(child: Text('일일 정산 내역이 없습니다'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dailySettlements.length,
            itemBuilder: (context, index) {
              final settlement = dailySettlements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('yyyy-MM-dd').format(settlement.settlementDate),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            '${settlement.orderCount}건',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDailyRow('매출액', settlement.totalSalesAmount, Colors.blue),
                      const SizedBox(height: 8),
                      _buildDailyRow('정산 완료', settlement.totalPaidAmount, Colors.green),
                      const SizedBox(height: 8),
                      _buildDailyRow('받을 금액', settlement.totalOutstandingAmount, Colors.orange),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: settlement.paymentRate / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          settlement.paymentRate >= 80 ? Colors.green : 
                          settlement.paymentRate >= 50 ? Colors.orange : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '정산율: ${settlement.paymentRate.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
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

  Widget _buildSettlementProcessing() {
    return Consumer<SettlementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('오류: ${provider.error}'));
        }

        final settlements = provider.settlements;
        final pendingSettlements = settlements.where((s) => s.status == 'PENDING').toList();
        
        if (pendingSettlements.isEmpty) {
          return const Center(child: Text('처리할 정산 내역이 없습니다'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingSettlements.length,
            itemBuilder: (context, index) {
              final settlement = pendingSettlements[index];
              
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
                              color: _SettlementColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.pending_outlined,
                              color: _SettlementColors.orange,
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('정산 금액', settlement.settlementAmount),
                      const SizedBox(height: 8),
                      _buildDetailRow('미수금', settlement.outstandingAmount),
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _showCompleteDialog(settlement),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _SettlementColors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '정산 완료 처리',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  void _showCompleteDialog(settlement) {
    final amountController = TextEditingController(
      text: settlement.outstandingAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정산 완료 처리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주문번호: ${settlement.orderId}'),
            const SizedBox(height: 8),
            Text('정산 금액: ${NumberFormat('#,###').format(settlement.settlementAmount)}원'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '입금 금액',
                border: OutlineInputBorder(),
                suffixText: '원',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올바른 금액을 입력하세요')),
                );
                return;
              }

              Navigator.pop(context);

              final settlementProvider = context.read<SettlementProvider>();
              
              final success = await settlementProvider.completeSettlement(
                settlement.settlementId,
                amount,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('정산이 완료되었습니다')),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('정산 처리 실패: ${settlementProvider.error}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int amount, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: _SettlementColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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

  Widget _buildDetailRow(String label, int amount) {
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _SettlementColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
