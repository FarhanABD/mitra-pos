import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';

class AddEditProductDialog extends ConsumerStatefulWidget {
  final ProductItem? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  ConsumerState<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends ConsumerState<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;

  String? _selectedCategory;
  String _selectedIcon = '📦';

  final List<String> _emojiOptions = ['📦', '☕', '🥤', '🍵', '🍫', '🥐', '🍛', '🍰', '🍕', '🍔', '🍦', '🧃', '🥪', '🍜'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '20');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _selectedCategory = p?.category;
    _selectedIcon = p?.icon ?? '📦';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori produk terlebih dahulu.')),
        );
        return;
      }

      final name = _nameController.text.trim();
      final price = int.parse(_priceController.text.trim());
      final costPrice = int.tryParse(_costPriceController.text.trim()) ?? 0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final sku = _skuController.text.trim();

      if (widget.product != null) {
        // Edit existing product
        final updated = widget.product!.copyWith(
          name: name,
          price: price,
          costPrice: costPrice,
          stock: stock,
          category: _selectedCategory!,
          sku: sku,
          icon: _selectedIcon,
        );
        ref.read(productListProvider.notifier).updateProduct(updated);
      } else {
        // Add new product
        final newProduct = ProductItem(
          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
          costPrice: costPrice,
          stock: stock,
          category: _selectedCategory!,
          sku: sku,
          icon: _selectedIcon,
        );
        ref.read(productListProvider.notifier).addProduct(newProduct);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    final isEdit = widget.product != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const Gap(12),

                // Icon Selection Row
                Text(
                  'Pilih Ikon Produk',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const Gap(8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _emojiOptions.map((emoji) {
                      final isSelected = _selectedIcon == emoji;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedIcon = emoji),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.secondaryColor.withValues(alpha: 0.2) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Gap(16),

                // Product Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'misal: Kopi Susu Aren',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama produk wajib diisi';
                    }
                    return null;
                  },
                ),
                const Gap(14),

                // Category Selection Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                ),
                const Gap(14),

                // Price & Cost Price Fields in Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga Jual (Rp)',
                          hintText: '25000',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (int.tryParse(val.trim()) == null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga Modal (Rp)',
                          hintText: '12000',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(14),

                // Stock & SKU Fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok Produk',
                          hintText: '20',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Stok wajib diisi';
                          }
                          if (int.tryParse(val.trim()) == null) {
                            return 'Stok harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(
                          labelText: 'Kode / SKU (Opsional)',
                          hintText: 'PRD-001',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Tambah Produk Sekarang',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
