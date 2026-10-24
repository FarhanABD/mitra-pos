import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/sales_repository.dart';
import '../../shop/data/shop_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final shop = ShopRepository.currentShop();
    final user = AuthRepository.currentUser();
    final shopName = shop?['name'] ?? 'Mitra POS';
    final shopType = shop?['businessType'] ?? 'Usaha UMKM';
    final userName = user?['name'] ?? 'Kasir Utama';

    String avatarText = 'MP';
    if (shopName.isNotEmpty) {
      final parts = shopName.trim().split(' ');
      if (parts.length >= 2) {
        avatarText = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        avatarText = shopName.substring(0, 1).toUpperCase();
      }
    }

    final allTransactions = ref.watch(salesProvider);
    final now = DateTime.now();
    final todayTrx = allTransactions.where((t) =>
      t.timestamp.year == now.year &&
      t.timestamp.month == now.month &&
      t.timestamp.day == now.day
    ).toList();

    final todayOmset = todayTrx.fold<int>(0, (sum, t) => sum + t.grandTotal);
    final todayTrxCount = todayTrx.length;
    final todayItemsSold = todayTrx.fold<int>(0, (sum, t) => sum + t.items.fold<int>(0, (iSum, i) => iSum + i.quantity));
    final avgOrder = todayTrxCount > 0 ? (todayOmset / todayTrxCount).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$shopType • $userName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifikasi',
          ),
          const Gap(8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(avatarText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const Gap(16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF49D26), Color(0xFF45A1B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF49D26).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang Kembali! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          'Kelola transaksi dan pantau omset tokomu hari ini dengan efisien.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        const Gap(16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.push('/pos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFF49D26),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.point_of_sale_rounded),
                              label: const Text(
                                'Buka Mesin POS',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/products'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5B67),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.inventory_2_rounded),
                              label: const Text(
                                'Kelola Katalog Produk',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Statistics Grid
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(12),
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
                    _StatCard(
                      title: 'Total Omset',
                      value: currencyFormatter.format(todayOmset),
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF10B981),
                      trend: todayTrxCount > 0 ? '$todayTrxCount Transaksi hari ini' : 'Belum ada omset hari ini',
                    ),
                    _StatCard(
                      title: 'Total Transaksi',
                      value: '$todayTrxCount Transaksi',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF4F46E5),
                      trend: todayTrxCount > 0 ? 'Tercatat hari ini' : '0 transaksi hari ini',
                    ),
                    _StatCard(
                      title: 'Produk Terjual',
                      value: '$todayItemsSold Pcs',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFFF59E0B),
                      trend: todayItemsSold > 0 ? 'Tercatat hari ini' : '0 pcs hari ini',
                    ),
                    _StatCard(
                      title: 'Rata-rata Order',
                      value: currencyFormatter.format(avgOrder),
                      icon: Icons.analytics_rounded,
                      color: const Color(0xFF8B5CF6),
                      trend: 'Rata-rata / transaksi',
                    ),
                  ],
                );
              },
            ),
            const Gap(24),

            // Quick Actions & Recent Transactions Split
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaksi Terakhir',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Gap(12),
                      allTransactions.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                                      const Gap(12),
                                      const Text(
                                        'Belum Ada Riwayat Transaksi',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const Gap(6),
                                      Text(
                                        'Toko ini masih baru dan belum memiliki transaksi penjualan.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                      ),
                                      const Gap(16),
                                      ElevatedButton.icon(
                                        onPressed: () => context.push('/pos'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0F5B67),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        ),
                                        icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                                        label: const Text('Buka Mesin POS'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Card(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: allTransactions.length > 5 ? 5 : allTransactions.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final trx = allTransactions[index];
                                  final itemsDesc = trx.items.map((i) => '${i.productName} x${i.quantity}').join(', ');
                                  final timeStr = '${trx.timestamp.hour.toString().padLeft(2, '0')}:${trx.timestamp.minute.toString().padLeft(2, '0')}';
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
                                      itemsDesc.isEmpty ? 'Transaksi Kasir' : itemsDesc,
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
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
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
            Text(
              trend,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
