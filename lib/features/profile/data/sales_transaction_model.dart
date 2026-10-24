class SalesItem {
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final String category;

  const SalesItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.category,
  });

  int get total => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'category': category,
    };
  }

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as int,
      category: json['category'] as String,
    );
  }
}

class SalesTransaction {
  final String id;
  final DateTime timestamp;
  final List<SalesItem> items;
  final int subtotal;
  final int tax;
  final int grandTotal;
  final String paymentMethod;

  const SalesTransaction({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
    this.paymentMethod = 'Tunai (Cash)',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
    };
  }

  factory SalesTransaction.fromJson(Map<String, dynamic> json) {
    return SalesTransaction(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      items: (json['items'] as List)
          .map((e) => SalesItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: json['subtotal'] as int,
      tax: json['tax'] as int,
      grandTotal: json['grandTotal'] as int,
      paymentMethod: (json['paymentMethod'] as String?) ?? 'Tunai (Cash)',
    );
  }
}

class TopProductSummary {
  final String productName;
  final String category;
  final int totalQuantitySold;
  final int totalRevenue;

  const TopProductSummary({
    required this.productName,
    required this.category,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });
}
