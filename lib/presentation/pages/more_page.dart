import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/chat_provider.dart';
import 'package:fresh_flow/presentation/pages/login_page.dart';
import 'package:fresh_flow/presentation/pages/store_registration_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_registration_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_recommendations_page.dart';
import 'package:fresh_flow/presentation/pages/group_buying_list_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_group_buying_page.dart';
import 'package:fresh_flow/presentation/pages/group_buying_my_participations_page.dart';
import 'package:fresh_flow/presentation/pages/store_settlement_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_settlement_page.dart';
import 'package:fresh_flow/injection_container.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isStoreOwner = user?.userType == 'STORE_OWNER';

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          '더보기',
          style: TextStyle(
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
              // 사용자 정보 카드
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
                              fontSize: 18,
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

              const SizedBox(height: 32),

              // 공동구매 섹션
              const Text(
                '공동구매',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 12),

              if (isStoreOwner) ...[
                _buildMenuItem(
                  context: context,
                  title: '공동구매 둘러보기',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GroupBuyingListPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  title: '내 참여 내역',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    if (user?.storeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('가게 정보를 찾을 수 없습니다')),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupBuyingMyParticipationsPage(
                          storeId: user!.storeId!,
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                _buildMenuItem(
                  context: context,
                  title: '공동구매 방 관리',
                  icon: Icons.group_work_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DistributorGroupBuyingPage(
                          distributorId: user?.distributorId ?? 'DIST001',
                          distributorName: user?.businessName ?? '유통업체',
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // 정산 섹션
              const Text(
                '정산',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                context: context,
                title: '정산 관리',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF06B6D4),
                onTap: () {
                  if (isStoreOwner) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StoreSettlementPage(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DistributorSettlementPage(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // 메뉴 섹션
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 12),

              if (isStoreOwner) ...[
                _buildMenuItem(
                  context: context,
                  title: '매장 정보 관리',
                  icon: Icons.store_outlined,
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
                const SizedBox(height: 8),
                _buildMenuItem(
                  context: context,
                  title: '유통업체 찾기',
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
              ] else ...[
                _buildMenuItem(
                  context: context,
                  title: '업체 정보 관리',
                  icon: Icons.business_outlined,
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
              ],

              const SizedBox(height: 32),

              // 로그아웃 버튼
              _buildMenuItem(
                context: context,
                title: '로그아웃',
                icon: Icons.logout_outlined,
                color: const Color(0xFFD4AF37),
                onTap: () => _showLogoutDialog(context, authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
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
          color: const Color(0xFF1F2937).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF9FAFB),
                ),
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

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 40,
                    color: Color(0xFFBFA470),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF9FAFB),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '오늘 하루도 수고 많으셨습니다.\n잠시 쉬어가시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFA470),
                      foregroundColor: const Color(0xFF1C1C1E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFBFA470),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
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
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.reset();
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
