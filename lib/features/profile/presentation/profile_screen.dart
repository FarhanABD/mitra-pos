import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../shop/data/shop_repository.dart';
import '../data/pdf_report_generator.dart';
import '../data/sales_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedPeriod = 'Semua Waktu';
  String _selectedSortBy = 'Paling Banyak Terjual';

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _handleExportReport() {
    final salesNotifier = ref.read(salesProvider.notifier);
    final csvData = salesNotifier.generateCsvExport(_selectedPeriod);
    final filteredTransactions = salesNotifier.getFilteredTransactions(_selectedPeriod);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryColor),
            Gap(8),
            Text('Ekspor Rekapan Penjualan'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan siap diunduh dalam format PDF untuk periode: $_selectedPeriod',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Gap(12),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvData,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Salin CSV'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Laporan CSV berhasil disalin ke clipboard!')),
              );
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Unduh PDF Laporan'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await PdfReportGenerator.generateAndDownloadPdf(
                transactions: filteredTransactions,
                period: _selectedPeriod,
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dan mereset sesi lokal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthRepository.logout();
              if (mounted) {
                ref.read(salesProvider.notifier).loadTransactions();
                context.go('/register');
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUser();
    final shop = ShopRepository.currentShop();

    final salesNotifier = ref.read(salesProvider.notifier);
    final filteredTransactions = salesNotifier.getFilteredTransactions(_selectedPeriod);
    final topProducts = salesNotifier.getTopSellingProducts(period: _selectedPeriod, sortBy: _selectedSortBy);

    // Calculate Summary Analytics
    final totalOmset = filteredTransactions.fold<int>(0, (sum, t) => sum + t.grandTotal);
    final totalTrx = filteredTransactions.length;
    final totalItemsSold = filteredTransactions.fold<int>(
      0,
      (sum, t) => sum + t.items.fold<int>(0, (iSum, item) => iSum + item.quantity),
    );
    final avgOrderValue = totalTrx > 0 ? (totalOmset / totalTrx).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil Toko & Rekapan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
            tooltip: 'Keluar Akun',
            onPressed: _handleLogout,
          ),
          const Gap(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F5B67).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, size: 36, color: AppTheme.primaryColor),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop?['name'] ?? 'Toko UMKM Mitra POS',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Gap(4),
                        Text(
                          '${shop?['businessType'] ?? 'Usaha UMKM'} • ${shop?['city'] ?? ''}, ${shop?['province'] ?? ''}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                        const Gap(2),
                        Text(
                          'Pemilik: ${user?['name'] ?? 'Kasir'} (${user?['email'] ?? ''})',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // 2. Sales Analytics Header & Period Filter Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                const Text(
                  'Rekapan Penjualan & Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _handleExportReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.file_download_rounded, size: 18),
                  label: const Text('Ekspor Laporan'),
                ),
              ],
            ),
            const Gap(12),

            // Period Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Hari Ini', '7 Hari Terakhir', 'Bulan Ini', 'Semua Waktu'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedPeriod = period);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(16),

            // 3. Stats Metric Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 700;
                final crossAxisCount = isDesktop ? 4 : 2;
                final aspectRatio = isDesktop ? 1.4 : 1.18;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspectRatio,
                  children: [
                    _MetricCard(
                      title: 'Total Omset',
                      value: currencyFormatter.format(totalOmset),
                      icon: Icons.payments_rounded,
                      color: AppTheme.accentColor,
                    ),
                    _MetricCard(
                      title: 'Total Transaksi',
                      value: '$totalTrx Transaksi',
                      icon: Icons.receipt_long_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    _MetricCard(
                      title: 'Produk Terjual',
                      value: '$totalItemsSold Pcs',
                      icon: Icons.inventory_2_rounded,
                      color: AppTheme.secondaryColor,
                    ),
                    _MetricCard(
                      title: 'Rata-rata Order',
                      value: currencyFormatter.format(avgOrderValue),
                      icon: Icons.analytics_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                );
              },
            ),
            const Gap(24),

            // 4. Top Selling Products Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🏆 Peringkat Produk Terlaris',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedSortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'Paling Banyak Terjual', child: Text('Terjual Terbanyak')),
                            DropdownMenuItem(value: 'Pendapatan Tertinggi', child: Text('Omset Tertinggi')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSortBy = val);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    topProducts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text('Belum ada data penjualan pada periode ini.')),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: topProducts.length > 5 ? 5 : topProducts.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = topProducts[index];
                              final rankBadgeColor = index == 0
                                  ? AppTheme.accentColor
                                  : index == 1
                                      ? Colors.blueGrey
                                      : index == 2
                                          ? Colors.brown.shade400
                                          : Colors.grey.shade400;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: rankBadgeColor.withValues(alpha: 0.2),
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(color: rankBadgeColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Kategori: ${item.category}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.totalQuantitySold} Terjual',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      currencyFormatter.format(item.totalRevenue),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            const Gap(24),

            // 5. Recent Transaction History List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧾 Riwayat Transaksi Selesai',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    filteredTransactions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text('Belum ada transaksi pada periode ini.')),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final trx = filteredTransactions[index];
                              final timeStr =
                                  '${trx.timestamp.hour.toString().padLeft(2, '0')}:${trx.timestamp.minute.toString().padLeft(2, '0')}';
                              final itemsSummary = trx.items.map((i) => '${i.productName} x${i.quantity}').join(', ');

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                                ),
                                title: Text(
                                  trx.id,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  itemsSummary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(trx.grandTotal),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
