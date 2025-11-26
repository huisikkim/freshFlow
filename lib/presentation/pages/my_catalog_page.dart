import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';
import 'package:fresh_flow/domain/entities/product.dart';
import 'package:fresh_flow/presentation/pages/product_form_page.dart';
import 'package:fresh_flow/injection_container.dart';

class MyCatalogPage extends StatefulWidget {
  const MyCatalogPage({super.key});

  @override
  State<MyCatalogPage> createState() => _MyCatalogPageState();
}

class _MyCatalogPageState extends State<MyCatalogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        title: const Text('내 상품 관리'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CatalogProvider>().loadMyProducts();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => InjectionContainer.getCatalogProvider(),
                child: const ProductFormPage(),
              ),
            ),
          ).then((_) {
            context.read<CatalogProvider>().loadMyProducts();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('상품 등록'),
        backgroundColor: const Color(0xFF06D6A0),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.state == CatalogState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF06D6A0),
              ),
            );
          }

          if (provider.state == CatalogState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? '조회 실패',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadMyProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06D6A0),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Color(0xFFA9B4C2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 상품이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D405B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '하단 버튼을 눌러 상품을 등록하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA9B4C2),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(provider.products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D405B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA9B4C2),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? const Color(0xFF06D6A0).withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.isAvailable ? '판매중' : '품절',
                    style: TextStyle(
                      color: product.isAvailable
                          ? const Color(0xFF06D6A0)
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Color(0xFFA9B4C2)),
                const SizedBox(width: 4),
                Text(
                  '${_formatNumber(product.unitPrice)}원/${product.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F61),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.inventory, size: 16, color: Color(0xFFA9B4C2)),
                const SizedBox(width: 4),
                Text(
                  '재고: ${product.stockQuantity}${product.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<int>(
                        context: context,
                        builder: (context) => _StockUpdateDialog(
                          currentStock: product.stockQuantity,
                        ),
                      );
                      if (result != null && mounted) {
                        await context
                            .read<CatalogProvider>()
                            .updateStock(product.id, result);
                        if (mounted) {
                          context.read<CatalogProvider>().loadMyProducts();
                        }
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('재고 수정'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF06D6A0),
                      side: const BorderSide(color: Color(0xFF06D6A0)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context
                          .read<CatalogProvider>()
                          .toggleAvailability(product.id);
                      if (mounted) {
                        context.read<CatalogProvider>().loadMyProducts();
                      }
                    },
                    icon: Icon(
                      product.isAvailable ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(product.isAvailable ? '품절 처리' : '판매 재개'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6F61),
                      side: const BorderSide(color: Color(0xFFFF6F61)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _StockUpdateDialog extends StatefulWidget {
  final int currentStock;

  const _StockUpdateDialog({required this.currentStock});

  @override
  State<_StockUpdateDialog> createState() => _StockUpdateDialogState();
}

class _StockUpdateDialogState extends State<_StockUpdateDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentStock.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('재고 수정'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: '재고 수량',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(_controller.text);
            if (quantity != null) {
              Navigator.pop(context, quantity);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06D6A0),
            foregroundColor: Colors.white,
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
