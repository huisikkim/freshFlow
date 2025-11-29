import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/pages/group_buying_list_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_group_buying_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isStoreOwner = user?.userType == 'STORE_OWNER';
    final isDistributor = user?.userType == 'DISTRIBUTOR';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          isStoreOwner ? '가게 관리' : '유통업체 관리',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isStoreOwner
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isStoreOwner ? Icons.store : Icons.local_shipping,
                      color: isStoreOwner
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.businessName ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isStoreOwner ? '가게 사장님' : '유통업체',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 환영 메시지
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isStoreOwner
                        ? [
                            const Color(0xFFEF4444).withOpacity(0.1),
                            const Color(0xFFFB923C).withOpacity(0.1),
                          ]
                        : [
                            const Color(0xFF10B981).withOpacity(0.1),
                            const Color(0xFF06D6A0).withOpacity(0.1),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요, ${user?.businessName ?? ''}님! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStoreOwner
                          ? '오늘도 신선한 식자재로 맛있는 요리를 준비하세요!'
                          : '오늘도 최고의 식자재를 공급해주세요!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 공동구매 배너
              InkWell(
                onTap: () {
                  if (isStoreOwner) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupBuyingListPage(),
                      ),
                    );
                  } else if (isDistributor) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DistributorGroupBuyingPage(
                          distributorId: user?.distributorId ?? 'DIST001',
                          distributorName: user?.businessName ?? '유통업체',
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isStoreOwner ? '🔥 공동구매 특가!' : '📦 공동구매 방 관리',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isStoreOwner
                                  ? '함께 구매하고 더 저렴하게!'
                                  : '공동구매 방을 만들고 관리하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 빠른 접근 안내
              const Text(
                '빠른 접근',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '하단 메뉴를 통해 주요 기능에 빠르게 접근하세요',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAccessIcon(
                          icon: Icons.receipt_long_outlined,
                          label: '주문',
                          color: const Color(0xFF10B981),
                        ),
                        _buildQuickAccessIcon(
                          icon: Icons.chat_bubble_outline,
                          label: '채팅',
                          color: const Color(0xFF4A90E2),
                        ),
                        _buildQuickAccessIcon(
                          icon: isStoreOwner
                              ? Icons.request_quote_outlined
                              : Icons.inventory_2_outlined,
                          label: isStoreOwner ? '견적' : '상품',
                          color: const Color(0xFF8B5CF6),
                        ),
                        _buildQuickAccessIcon(
                          icon: Icons.menu,
                          label: '더보기',
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // 하단 네비게이션 바 공간
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessIcon({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
