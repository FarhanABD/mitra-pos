import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';
import 'add_edit_product_dialog.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama Kategori (misal: Minuman Boba)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(categoryListProvider.notifier).addCategory(text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _openAddEditProductDialog([ProductItem? product]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditProductDialog(product: product),
    );
  }

  void _confirmDelete(ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus produk "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              ref.read(productListProvider.notifier).deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Produk ${product.name} telah dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);
    final categories = ref.watch(categoryListProvider);

    // Filter Logic
    final filteredProducts = products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Katalog & Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Tambah Kategori',
            onPressed: _showAddCategoryDialog,
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditProductDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Top Search & Category Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari produk atau kode SKU...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
                const Gap(12),
                // Category Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('Semua'),
                          selected: _selectedCategory == 'Semua',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategory = 'Semua');
                          },
                        ),
                      ),
                      ...categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: const Text('Kategori Baru'),
                        onPressed: _showAddCategoryDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Product List View
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const Gap(12),
                        Text(
                          'Tidak ada produk ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                        ),
                        const Gap(4),
                        Text(
                          'Klik tombol Tambah Produk di bawah untuk mendaftarkan barang baru.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              // Product Icon/Emoji Container
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(product.icon, style: const TextStyle(fontSize: 26)),
                                ),
                              ),
                              const Gap(14),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const Gap(8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(6),
                                    Row(
                                      children: [
                                        Text(
                                          currencyFormatter.format(product.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const Gap(16),
                                        Text(
                                          'Stok: ${product.stock} pcs',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: product.stock < 10 ? AppTheme.errorColor : Colors.grey.shade600,
                                            fontWeight: product.stock < 10 ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Actions (Edit & Delete)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                                tooltip: 'Edit Produk',
                                onPressed: () => _openAddEditProductDialog(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
                                tooltip: 'Hapus Produk',
                                onPressed: () => _confirmDelete(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
