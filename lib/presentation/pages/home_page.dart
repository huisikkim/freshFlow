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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: Text(
          isStoreOwner ? '가게 관리' : '유통업체 관리',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE5E7EB),
          ),
        ),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보 헤더
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isStoreOwner ? Icons.storefront : Icons.local_shipping,
                        color: const Color(0xFFD4AF37),
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF9FAFB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isStoreOwner ? '가게 사장님' : '유통업체',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 환영 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요, ${user?.businessName ?? ''}님! 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF9FAFB),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStoreOwner
                          ? '오늘도 신선한 식자재로 맛있는 요리를 준비하세요!'
                          : '오늘도 최고의 식자재를 공급해주세요!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFD1D5DB),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(16),
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
                          size: 28,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isStoreOwner
                                  ? '함께 구매하고 더 저렴하게!'
                                  : '공동구매 방을 만들고 관리하세요',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 18,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '하단 메뉴를 통해 주요 기능에 빠르게 접근하세요',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
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
                          icon: Icons.receipt_long,
                          label: '주문',
                        ),
                        _buildQuickAccessIcon(
                          icon: Icons.chat_bubble,
                          label: '채팅',
                        ),
                        _buildQuickAccessIcon(
                          icon: isStoreOwner
                              ? Icons.request_quote
                              : Icons.inventory_2,
                          label: isStoreOwner ? '견적' : '상품',
                        ),
                        _buildQuickAccessIcon(
                          icon: Icons.more_horiz,
                          label: '더보기',
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
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD4AF37),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD1D5DB),
          ),
        ),
      ],
    );
  }
}
