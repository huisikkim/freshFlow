import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/auth_provider.dart';
import 'package:fresh_flow/presentation/providers/chat_provider.dart';
import 'package:fresh_flow/presentation/pages/home_page.dart';
import 'package:fresh_flow/presentation/pages/order_list_page.dart';
import 'package:fresh_flow/presentation/pages/distributor_order_list_page.dart';
import 'package:fresh_flow/presentation/pages/chat/chat_list_page.dart';
import 'package:fresh_flow/presentation/pages/quote_request_list_page.dart';
import 'package:fresh_flow/presentation/pages/my_catalog_page.dart';
import 'package:fresh_flow/presentation/pages/more_page.dart';
import 'package:fresh_flow/injection_container.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isStoreOwner = user?.userType == 'STORE_OWNER';

    final pages = isStoreOwner ? _storeOwnerPages() : _distributorPages();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFF374151),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: isStoreOwner
                      ? _buildStoreOwnerNavButtons()
                      : _buildDistributorNavButtons(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _storeOwnerPages() {
    return [
      const HomePage(),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getOrderProvider(),
        child: const OrderListPage(),
      ),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getChatProvider(),
        child: const ChatListPage(),
      ),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getQuoteRequestProvider(),
        child: const QuoteRequestListPage(isDistributor: false),
      ),
      const MorePage(),
    ];
  }

  List<Widget> _distributorPages() {
    return [
      const HomePage(),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getOrderProvider(),
        child: const DistributorOrderListPage(),
      ),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getChatProvider(),
        child: const ChatListPage(),
      ),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getCatalogProvider(),
        child: const MyCatalogPage(),
      ),
      ChangeNotifierProvider(
        create: (_) => InjectionContainer.getQuoteRequestProvider(),
        child: const QuoteRequestListPage(isDistributor: true),
      ),
      const MorePage(),
    ];
  }

  List<Widget> _buildStoreOwnerNavButtons() {
    final authProvider = context.watch<AuthProvider>();
    final isStoreOwner = authProvider.user?.userType == 'STORE_OWNER';
    
    return [
      _buildNavButton(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: '홈',
        index: 0,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: '주문',
        index: 1,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: '채팅',
        index: 2,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.request_quote_outlined,
        activeIcon: Icons.request_quote,
        label: '견적',
        index: 3,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.menu,
        activeIcon: Icons.menu,
        label: '더보기',
        index: 4,
        isStoreOwner: isStoreOwner,
      ),
    ];
  }

  List<Widget> _buildDistributorNavButtons() {
    final authProvider = context.watch<AuthProvider>();
    final isStoreOwner = authProvider.user?.userType == 'STORE_OWNER';
    
    return [
      _buildNavButton(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: '홈',
        index: 0,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: '주문',
        index: 1,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: '채팅',
        index: 2,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: '상품',
        index: 3,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
        label: '견적',
        index: 4,
        isStoreOwner: isStoreOwner,
      ),
      _buildNavButton(
        icon: Icons.menu,
        activeIcon: Icons.menu,
        label: '더보기',
        index: 5,
        isStoreOwner: isStoreOwner,
      ),
    ];
  }

  Widget _buildNavButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isStoreOwner,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive
        ? const Color(0xFFD4AF37)
        : const Color(0xFF9CA3AF);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
