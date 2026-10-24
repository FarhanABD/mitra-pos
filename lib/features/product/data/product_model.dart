class ProductItem {
  final String id;
  final String name;
  final int price;
  final int costPrice;
  final int stock;
  final String category;
  final String sku;
  final String icon;

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.costPrice = 0,
    this.stock = 10,
    required this.category,
    this.sku = '',
    this.icon = '📦',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'category': category,
      'sku': sku,
      'icon': icon,
    };
  }

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      costPrice: (json['costPrice'] as int?) ?? 0,
      stock: (json['stock'] as int?) ?? 0,
      category: json['category'] as String,
      sku: (json['sku'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '📦',
    );
  }

  ProductItem copyWith({
    String? id,
    String? name,
    int? price,
    int? costPrice,
    int? stock,
    String? category,
    String? sku,
    String? icon,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      icon: icon ?? this.icon,
    );
  }
}
