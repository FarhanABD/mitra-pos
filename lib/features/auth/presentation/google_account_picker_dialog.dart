import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../product/data/product_repository.dart';
import '../../profile/data/sales_repository.dart';
import '../../shop/data/shop_repository.dart';
import '../data/auth_repository.dart';

class GoogleAccountItem {
  final String name;
  final String email;
  final String letter;
  final Color avatarColor;

  const GoogleAccountItem({
    required this.name,
    required this.email,
    required this.letter,
    required this.avatarColor,
  });
}

class GoogleAccountPickerDialog {
  static const List<GoogleAccountItem> defaultGoogleAccounts = [
    GoogleAccountItem(
      name: 'Mokhamad Farhan Abdillah',
      email: 'farhanabdilah204@gmail.com',
      letter: 'F',
      avatarColor: Color(0xFF0F7E66),
    ),
    GoogleAccountItem(
      name: 'najwa amalia',
      email: 'najwa.am2003@gmail.com',
      letter: 'n',
      avatarColor: Color(0xFF7B1FA2),
    ),
    GoogleAccountItem(
      name: 'M Farhan Abdillah',
      email: 'farhanyutub068@gmail.com',
      letter: 'M',
      avatarColor: Color(0xFF2E7D32),
    ),
    GoogleAccountItem(
      name: 'Abdillah',
      email: 'abdilahfarhan2003@gmail.com',
      letter: 'A',
      avatarColor: Color(0xFF8E24AA),
    ),
    GoogleAccountItem(
      name: 'E41210004 Mokhamad Farhan Ab...',
      email: 'e41210004@student.polije.ac.id',
      letter: 'E',
      avatarColor: Color(0xFF00695C),
    ),
  ];

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      await showDialog(
        context: context,
        builder: (dialogCtx) => Dialog(
          backgroundColor: const Color(0xFF28292A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _PickerContent(ref: ref),
          ),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF28292A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetCtx) => SafeArea(
          child: _PickerContent(ref: ref),
        ),
      );
    }
  }
}

class _PickerContent extends StatefulWidget {
  final WidgetRef ref;
  const _PickerContent({required this.ref});

  @override
  State<_PickerContent> createState() => _PickerContentState();
}

class _PickerContentState extends State<_PickerContent> {
  Future<void> _selectAccount(String name, String email) async {
    Navigator.of(context).pop();

    await AuthRepository.loginOrRegisterGoogleUser(name: name, email: email);

    // Refresh memory providers for clean state of the logged in user
    widget.ref.read(salesProvider.notifier).loadTransactions();
    widget.ref.read(productListProvider.notifier).loadProducts();
    widget.ref.read(categoryListProvider.notifier).loadCategories();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil masuk dengan Google ($name)'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      final hasShop = ShopRepository.hasShop();
      if (hasShop) {
        context.go('/');
      } else {
        context.go('/shop-setup');
      }
    }
  }

  void _showAddCustomAccount() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF303134),
        title: const Text('Tambahkan Akun Google', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const Gap(12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Alamat Email Google',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              if (emailCtrl.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                final name = nameCtrl.text.trim().isEmpty ? emailCtrl.text.trim().split('@')[0] : nameCtrl.text.trim();
                _selectAccount(name, emailCtrl.text.trim());
              }
            },
            child: const Text('Gunakan Akun'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(16),

          // Google App Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0F7E66),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 28),
            ),
          ),
          const Gap(14),

          // Header Text
          const Text(
            'Pilih akun',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          const Text(
            'untuk melanjutkan ke Mitra Digital POS',
            style: TextStyle(
              color: Color(0xFFBDC1C6),
              fontSize: 13,
            ),
          ),
          const Gap(18),

          // Accounts List
          ...GoogleAccountPickerDialog.defaultGoogleAccounts.map((account) {
            return InkWell(
              onTap: () => _selectAccount(account.name, account.email),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: account.avatarColor,
                      child: Text(
                        account.letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            account.email,
                            style: const TextStyle(
                              color: Color(0xFF9AA0A6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const Gap(4),
          const Divider(color: Color(0xFF3C4043), height: 16),
          const Gap(4),

          // Add Another Account Option
          InkWell(
            onTap: _showAddCustomAccount,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.person_add_alt_outlined, color: Colors.white70, size: 24),
                  ),
                  Gap(16),
                  Text(
                    'Tambahkan akun lain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Gap(16),

          // Disclaimer Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Color(0xFF9AA0A6),
                  fontSize: 11,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Untuk melanjutkan, Google akan membagikan nama, alamat email, dan foto profil Anda ke Mitra Digital POS. Sebelum menggunakan aplikasi ini, tinjau ',
                  ),
                  TextSpan(
                    text: 'kebijakan privasi',
                    style: const TextStyle(color: Color(0xFF8AB4F8), fontWeight: FontWeight.w500),
                  ),
                  const TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'persyaratan layanannya',
                    style: const TextStyle(color: Color(0xFF8AB4F8), fontWeight: FontWeight.w500),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
