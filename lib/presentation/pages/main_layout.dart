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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: isStoreOwner 
              ? const Color(0xFFEF4444) 
              : const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: isStoreOwner 
              ? _storeOwnerNavItems() 
              : _distributorNavItems(),
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
      const MorePage(),
    ];
  }

  List<BottomNavigationBarItem> _storeOwnerNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: '주문',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: '채팅',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.request_quote_outlined),
        activeIcon: Icon(Icons.request_quote),
        label: '견적',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu),
        activeIcon: Icon(Icons.menu),
        label: '더보기',
      ),
    ];
  }

  List<BottomNavigationBarItem> _distributorNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '홈',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: '주문',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: '채팅',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        activeIcon: Icon(Icons.inventory_2),
        label: '상품',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu),
        activeIcon: Icon(Icons.menu),
        label: '더보기',
      ),
    ];
  }
}
