import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';
import 'sales_transaction_model.dart';

class SalesNotifier extends StateNotifier<List<SalesTransaction>> {
  SalesNotifier() : super([]) {
    loadTransactions();
  }

  void loadTransactions() {
    final raw = LocalDatabase.getTransactions();
    if (raw != null && raw.isNotEmpty) {
      state = raw.map((e) => SalesTransaction.fromJson(e)).toList();
    } else {
      state = [];
    }
  }

  Future<void> clearTransactions() async {
    state = [];
    await LocalDatabase.clearCurrentUserTransactions();
  }

  Future<void> addTransaction(SalesTransaction transaction) async {
    final updated = [transaction, ...state];
    state = updated;
    await saveToDatabase(updated);
  }

  Future<void> saveToDatabase(List<SalesTransaction> transactions) async {
    await LocalDatabase.saveTransactions(transactions.map((t) => t.toJson()).toList());
  }

  // Get Top Selling Products
  List<TopProductSummary> getTopSellingProducts({String period = 'Semua Waktu', String sortBy = 'Paling Banyak Terjual'}) {
    final filtered = _filterByPeriod(state, period);
    final Map<String, _AggregatedItem> aggMap = {};

    for (final trx in filtered) {
      for (final item in trx.items) {
        if (!aggMap.containsKey(item.productName)) {
          aggMap[item.productName] = _AggregatedItem(
            name: item.productName,
            category: item.category,
            quantity: 0,
            revenue: 0,
          );
        }
        aggMap[item.productName]!.quantity += item.quantity;
        aggMap[item.productName]!.revenue += item.total;
      }
    }

    final list = aggMap.values.map((e) => TopProductSummary(
      productName: e.name,
      category: e.category,
      totalQuantitySold: e.quantity,
      totalRevenue: e.revenue,
    )).toList();

    if (sortBy == 'Pendapatan Tertinggi') {
      list.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    } else {
      // Paling Banyak Terjual
      list.sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));
    }

    return list;
  }

  // Filter Transactions by Time Period
  List<SalesTransaction> getFilteredTransactions(String period) {
    return _filterByPeriod(state, period);
  }

  List<SalesTransaction> _filterByPeriod(List<SalesTransaction> transactions, String period) {
    final now = DateTime.now();
    if (period == 'Hari Ini') {
      return transactions.where((t) =>
        t.timestamp.year == now.year &&
        t.timestamp.month == now.month &&
        t.timestamp.day == now.day
      ).toList();
    } else if (period == '7 Hari Terakhir') {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return transactions.where((t) => t.timestamp.isAfter(sevenDaysAgo)).toList();
    } else if (period == 'Bulan Ini') {
      return transactions.where((t) =>
        t.timestamp.year == now.year &&
        t.timestamp.month == now.month
      ).toList();
    }
    return transactions;
  }

  // Generate CSV text string for export
  String generateCsvExport(String period) {
    final list = getFilteredTransactions(period);
    final buffer = StringBuffer();
    buffer.writeln('ID Transaksi,Tanggal,Waktu,Metode Pembayaran,Total Item,Grand Total (Rp)');

    for (final trx in list) {
      final dateStr = '${trx.timestamp.day}/${trx.timestamp.month}/${trx.timestamp.year}';
      final timeStr = '${trx.timestamp.hour.toString().padLeft(2, '0')}:${trx.timestamp.minute.toString().padLeft(2, '0')}';
      final itemQty = trx.items.fold<int>(0, (sum, i) => sum + i.quantity);
      buffer.writeln('${trx.id},$dateStr,$timeStr,"${trx.paymentMethod}",$itemQty,${trx.grandTotal}');
    }

    return buffer.toString();
  }
}

class _AggregatedItem {
  final String name;
  final String category;
  int quantity;
  int revenue;

  _AggregatedItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.revenue,
  });
}

final salesProvider = StateNotifierProvider<SalesNotifier, List<SalesTransaction>>((ref) {
  return SalesNotifier();
});
