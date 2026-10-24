import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../product/data/product_model.dart';
import '../../product/data/product_repository.dart';
import '../../profile/data/sales_repository.dart';
import '../../profile/data/sales_transaction_model.dart';

// Cart Item Model using ProductItem
class CartItem {
  final ProductItem product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Riverpod Cart StateNotifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductItem product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = List<CartItem>.from(state);
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeFromCart(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity > 1) {
        final updated = List<CartItem>.from(state);
        updated[index] = item.copyWith(quantity: item.quantity - 1);
        state = updated;
      } else {
        state = state.where((i) => i.product.id != productId).toList();
      }
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final cart = ref.watch(cartProvider);
    final products = ref.watch(productListProvider);
    final categories = ref.watch(categoryListProvider);

    final filteredProducts = products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'Semua' || p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final subtotal = cart.fold<int>(0, (sum, item) => sum + (item.product.price * item.quantity));
    final tax = (subtotal * 0.1).round();
    final grandTotal = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesin Kasir (POS)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Kosongkan Keranjang',
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          ),
          const Gap(16),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Product Selector
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Barcode
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari produk atau scan barcode...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const Gap(12),
                      IconButton.filledTonal(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        padding: const EdgeInsets.all(14),
                      ),
                    ],
                  ),
                  const Gap(16),

                  // Category Filter Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Semua'),
                            selected: selectedCategory == 'Semua',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedCategory = 'Semua';
                                });
                              }
                            },
                          ),
                        ),
                        ...categories.map((category) {
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Product Grid
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(
                            child: Text('Tidak ada produk tersedia'),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return InkWell(
                                onTap: () {
                                  ref.read(cartProvider.notifier).addToCart(product);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(product.icon, style: const TextStyle(fontSize: 36)),
                                        const Gap(8),
                                        Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const Gap(4),
                                        Text(
                                          currencyFormatter.format(product.price),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side: Cart Summary Panel
          Container(
            width: 340,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Pesanan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text('${cart.fold<int>(0, (s, i) => s + i.quantity)} Items'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Cart Item List
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text('Keranjang masih kosong'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: cart.length,
                          separatorBuilder: (context, index) => const Gap(12),
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        currencyFormatter.format(item.product.price),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => ref.read(cartProvider.notifier).removeFromCart(item.product.id),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => ref.read(cartProvider.notifier).addToCart(item.product),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // Summary Payment Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(currencyFormatter.format(subtotal)),
                        ],
                      ),
                      const Gap(6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pajak (PB1 10%)'),
                          Text(currencyFormatter.format(tax)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            currencyFormatter.format(grandTotal),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: cart.isEmpty
                              ? null
                              : () async {
                                  final newTrx = SalesTransaction(
                                    id: '#TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                    timestamp: DateTime.now(),
                                    items: cart
                                        .map((i) => SalesItem(
                                              productId: i.product.id,
                                              productName: i.product.name,
                                              quantity: i.quantity,
                                              unitPrice: i.product.price,
                                              category: i.product.category,
                                            ))
                                        .toList(),
                                    subtotal: subtotal,
                                    tax: tax,
                                    grandTotal: grandTotal,
                                    paymentMethod: 'Tunai (Cash)',
                                  );

                                  await ref.read(salesProvider.notifier).addTransaction(newTrx);

                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Pembayaran Berhasil! 🎉'),
                                        content: Text('Total Transaksi: ${currencyFormatter.format(grandTotal)}\nStruk telah dikirim ke printer.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).clearCart();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Selesai'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Bayar Sekarang'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
