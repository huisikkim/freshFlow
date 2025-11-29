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
import 'package:fresh_flow/injection_container.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isStoreOwner = user?.userType == 'STORE_OWNER';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          '더보기',
          style: TextStyle(
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
              // 사용자 정보 카드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 4),
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
              ),

              const SizedBox(height: 32),

              // 공동구매 섹션
              const Text(
                '공동구매',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
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

              // 메뉴 섹션
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
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
                color: const Color(0xFFEF4444),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                  color: Color(0xFF111827),
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
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
                          color: Color(0xFFFB923C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '오늘 하루도 수고 많으셨습니다.\n잠시 쉬어가시겠어요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                            backgroundColor: const Color(0xFFFB923C),
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
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8F0),
                            foregroundColor: const Color(0xFF475569),
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
                Positioned(
                  top: -64,
                  right: -64,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7AA).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -48,
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA5F3FC).withOpacity(0.5),
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
