import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import 'product_model.dart';

// Sample Default Products
const List<ProductItem> defaultSampleProducts = [
  ProductItem(id: 'p1', name: 'Kopi Susu Aren', price: 25000, costPrice: 12000, stock: 45, category: 'Kopi', icon: '☕'),
  ProductItem(id: 'p2', name: 'Americano Hot', price: 22000, costPrice: 10000, stock: 30, category: 'Kopi', icon: '☕'),
  ProductItem(id: 'p3', name: 'Caramel Macchiato', price: 32000, costPrice: 15000, stock: 25, category: 'Kopi', icon: '🥤'),
  ProductItem(id: 'p4', name: 'Matcha Latte', price: 28000, costPrice: 13000, stock: 20, category: 'Non-Kopi', icon: '🍵'),
  ProductItem(id: 'p5', name: 'Chocolate Ice', price: 26000, costPrice: 12000, stock: 35, category: 'Non-Kopi', icon: '🍫'),
  ProductItem(id: 'p6', name: 'Croissant Butter', price: 24000, costPrice: 11000, stock: 18, category: 'Makanan', icon: '🥐'),
  ProductItem(id: 'p7', name: 'Nasi Goreng Special', price: 35000, costPrice: 18000, stock: 50, category: 'Makanan', icon: '🍛'),
  ProductItem(id: 'p8', name: 'Red Velvet Cake', price: 30000, costPrice: 14000, stock: 12, category: 'Dessert', icon: '🍰'),
];

// Sample Default Categories
const List<String> defaultSampleCategories = ['Kopi', 'Non-Kopi', 'Makanan', 'Dessert', 'Lainnya'];

class ProductListNotifier extends StateNotifier<List<ProductItem>> {
  ProductListNotifier() : super([]) {
    loadProducts();
  }

  void loadProducts() {
    final raw = LocalDatabase.getProducts();
    if (raw != null && raw.isNotEmpty) {
      state = raw.map((e) => ProductItem.fromJson(e)).toList();
    } else {
      state = List.from(defaultSampleProducts);
      saveToDatabase(state);
    }
  }

  Future<void> addProduct(ProductItem product) async {
    final updated = [...state, product];
    state = updated;
    await saveToDatabase(updated);
  }

  Future<void> updateProduct(ProductItem product) async {
    final updated = state.map((p) => p.id == product.id ? product : p).toList();
    state = updated;
    await saveToDatabase(updated);
  }

  Future<void> deleteProduct(String id) async {
    final updated = state.where((p) => p.id != id).toList();
    state = updated;
    await saveToDatabase(updated);
  }

  Future<void> saveToDatabase(List<ProductItem> products) async {
    await LocalDatabase.saveProducts(products.map((p) => p.toJson()).toList());
  }
}

final productListProvider = StateNotifierProvider<ProductListNotifier, List<ProductItem>>((ref) {
  return ProductListNotifier();
});

class CategoryListNotifier extends StateNotifier<List<String>> {
  CategoryListNotifier() : super([]) {
    loadCategories();
  }

  void loadCategories() {
    final raw = LocalDatabase.getCategories();
    if (raw != null && raw.isNotEmpty) {
      state = raw;
    } else {
      state = List.from(defaultSampleCategories);
      LocalDatabase.saveCategories(state);
    }
  }

  Future<void> addCategory(String category) async {
    if (category.trim().isEmpty || state.contains(category.trim())) return;
    final updated = [...state, category.trim()];
    state = updated;
    await LocalDatabase.saveCategories(updated);
  }
}

final categoryListProvider = StateNotifierProvider<CategoryListNotifier, List<String>>((ref) {
  return CategoryListNotifier();
});
