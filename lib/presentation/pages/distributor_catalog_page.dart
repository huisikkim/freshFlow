import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';
import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/presentation/pages/product_detail_page.dart';
import 'package:fresh_flow/presentation/pages/cart_page.dart';
import 'package:fresh_flow/injection_container.dart';
import 'package:intl/intl.dart';

/// 유통업체의 상품 목록을 표시하는 페이지
/// Single Responsibility: 상품 목록 표시와 필터링만 담당
class DistributorCatalogPage extends StatefulWidget {
  final String distributorId;
  final String distributorName;

  const DistributorCatalogPage({
    super.key,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<DistributorCatalogPage> createState() =>
      _DistributorCatalogPageState();
}

class _DistributorCatalogPageState extends State<DistributorCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<CatalogProvider>().loadDistributorCatalog(widget.distributorId);
  }

  void _searchProducts() {
    if (_searchKeyword.isEmpty) {
      _loadProducts();
    } else {
      context
          .read<CatalogProvider>()
          .searchProducts(widget.distributorId, _searchKeyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: _buildCartButton(),
    );
  }

  /// Open/Closed Principle: AppBar 구성을 별도 메서드로 분리
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.distributorName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF18181B),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
        color: const Color(0xFF18181B),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 24),
          onPressed: _loadProducts,
          tooltip: '새로고침',
          color: const Color(0xFF18181B),
        ),
      ],
    );
  }

  /// Single Responsibility: 검색바 UI만 담당
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: const Color(0xFFF8FAFC),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '상품 검색...',
          hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A1AA)),
          suffixIcon: _searchKeyword.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFA1A1AA)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchKeyword = '');
                    _loadProducts();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF10B981)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _searchKeyword = value);
        },
        onSubmitted: (_) => _searchProducts(),
      ),
    );
  }

  /// Dependency Inversion: Provider를 통해 데이터 접근
  Widget _buildProductList() {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        if (provider.state == CatalogState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.state == CatalogState.error) {
          return _buildErrorView(provider.errorMessage);
        }

        if (provider.products.isEmpty) {
          return _buildEmptyView();
        }

        return _buildProductGrid(provider.products);
      },
    );
  }

  /// Single Responsibility: 에러 상태 UI만 담당
  Widget _buildErrorView(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(errorMessage ?? '오류가 발생했습니다'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// Single Responsibility: 빈 상태 UI만 담당
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchKeyword.isEmpty ? '등록된 상품이 없습니다' : '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          if (_searchKeyword.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchKeyword = '');
                _loadProducts();
              },
              child: const Text('전체 상품 보기'),
            ),
          ],
        ],
      ),
    );
  }

  /// Open/Closed Principle: 그리드 레이아웃을 쉽게 변경 가능
  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // 0.75에서 0.7로 변경 (더 세로로 길게)
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () => _navigateToProductDetail(products[index]),
        );
      },
    );
  }

  /// Single Responsibility: 네비게이션 로직 분리
  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => InjectionContainer.getCatalogProvider(),
          child: ProductDetailPage(productId: product.id),
        ),
      ),
    );
  }

  /// Single Responsibility: 장바구니 버튼 UI만 담당
  Widget _buildCartButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getCartProvider(),
                child: CartPage(
                  distributorId: widget.distributorId,
                  distributorName: widget.distributorName,
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shopping_cart, size: 20),
            SizedBox(width: 8),
            Text(
              '장바구니',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single Responsibility: 상품 카드 UI만 담당
/// Open/Closed Principle: 상품 카드 디자인을 독립적으로 수정 가능
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProductName(),
                  const SizedBox(height: 4),
                  _buildProductPrice(numberFormat),
                  const SizedBox(height: 8),
                  _buildStockBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Flexible(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: product.imageUrl != null
            ? ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    );
                  },
                ),
              )
            : const Center(
                child: Icon(Icons.image, size: 48, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      product.productName,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF27272A),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductPrice(NumberFormat numberFormat) {
    final isAvailable = product.isAvailable && product.stockQuantity > 0;
    
    if (!isAvailable) {
      return const Text(
        '품절',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEF4444),
        ),
      );
    }
    
    return Text(
      '${numberFormat.format(product.unitPrice)}원/${product.unit}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF10B981),
      ),
    );
  }

  Widget _buildStockBadge() {
    final isAvailable = product.isAvailable && product.stockQuantity > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? '재고 있음' : '재고 없음',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isAvailable
              ? const Color(0xFF059669)
              : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}
