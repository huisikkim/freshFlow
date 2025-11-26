import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/pages/login_page.dart';
import 'package:fresh_flow/presentation/pages/store_registration_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_registration_page.dart';
import 'package:fresh_flow/presentation/pages/quote_request_list_page.dart';
import 'package:fresh_flow/presentation/pages/my_catalog_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_recommendations_page.dart';
import 'package:fresh_flow/presentation/pages/order_list_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_order_list_page.dart';
import 'package:fresh_flow/injection_container.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF6B7280)),
            tooltip: '로그아웃',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                barrierColor: const Color(0xFF0F172A).withOpacity(0.1),
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 메인 다이얼로그 컨테이너 (맨 뒤)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB), // amber-50 더 연하게
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 50,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 해질녘 아이콘 (흰색 배경)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.wb_twilight,
                                    size: 50,
                                    color: Color(0xFFFB923C), // orange-400
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // 제목
                                const Text(
                                  '로그아웃',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B), // slate-800
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // 설명
                                const Text(
                                  '오늘 하루도 수고 많으셨습니다.\n잠시 쉬어가시겠어요?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569), // slate-600
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // 로그아웃 버튼
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFB923C).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFB923C), // orange-400
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: const Text(
                                      '로그아웃',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // 취소 버튼
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE2E8F0), // slate-200
                                      foregroundColor: const Color(0xFF475569), // slate-600
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 장식용 원형 배경 (오른쪽 위) - 버튼 바로 뒤
                          Positioned(
                            top: -64,
                            right: -64,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFED7AA).withOpacity(0.5), // orange-200 반투명
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          
                          // 장식용 원형 배경 (왼쪽 아래) - 버튼 바로 뒤
                          Positioned(
                            bottom: -80,
                            left: -48,
                            child: Container(
                              width: 192,
                              height: 192,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA5F3FC).withOpacity(0.5), // cyan-200 반투명
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              
              if (confirm == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              }
            },
          ),
        ],
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

              const SizedBox(height: 40),

              // 주요 기능 섹션
              const Text(
                '주요 기능',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              
              if (isStoreOwner) ..._buildStoreOwnerMenu(context),
              if (isDistributor) ..._buildDistributorMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoreOwnerMenu(BuildContext context) {
    return [
      _buildMenuCard(
        context: context,
        title: '주문 내역',
        subtitle: '주문한 내역 확인',
        icon: Icons.receipt_long,
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getOrderProvider(),
                child: const OrderListPage(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '견적 요청하기',
        subtitle: '필요한 식자재 견적 요청',
        icon: Icons.request_quote,
        color: const Color(0xFF3B82F6),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getQuoteRequestProvider(),
                child: const QuoteRequestListPage(isDistributor: false),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '유통업체 찾기',
        subtitle: '추천 유통업체 확인',
        icon: Icons.search,
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getMatchingProvider(),
                child: const DistributorRecommendationsPage(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '매장 정보 관리',
        subtitle: '매장 정보 등록 및 수정',
        icon: Icons.store,
        color: const Color(0xFFEC4899),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getStoreProvider(),
                child: const StoreRegistrationPage(),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildDistributorMenu(BuildContext context) {
    return [
      _buildMenuCard(
        context: context,
        title: '받은 주문',
        subtitle: '가게에서 받은 주문 확인',
        icon: Icons.receipt_long,
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getOrderProvider(),
                child: const DistributorOrderListPage(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '상품 관리',
        subtitle: '판매 상품 등록 및 관리',
        icon: Icons.inventory_2,
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getCatalogProvider(),
                child: const MyCatalogPage(),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '견적 요청 확인',
        subtitle: '받은 견적 요청 관리',
        icon: Icons.inbox,
        color: const Color(0xFF3B82F6),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getQuoteRequestProvider(),
                child: const QuoteRequestListPage(isDistributor: true),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      _buildMenuCard(
        context: context,
        title: '업체 정보 관리',
        subtitle: '유통업체 정보 등록 및 수정',
        icon: Icons.business,
        color: const Color(0xFFF59E0B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getDistributorProvider(),
                child: const DistributorRegistrationPage(),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
