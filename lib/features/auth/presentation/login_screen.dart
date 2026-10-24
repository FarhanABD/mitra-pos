import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../product/data/product_repository.dart';
import '../../profile/data/sales_repository.dart';
import '../../shop/data/shop_repository.dart';
import '../data/auth_repository.dart';
import 'google_account_picker_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final isValid = await AuthRepository.loginUser(email: email, password: password);

      if (isValid && mounted) {
        // Refresh Riverpod state for logged in user
        ref.read(salesProvider.notifier).loadTransactions();
        ref.read(productListProvider.notifier).loadProducts();
        ref.read(categoryListProvider.notifier).loadCategories();

        final hasShop = ShopRepository.hasShop();
        if (hasShop) {
          context.go('/');
        } else {
          context.go('/shop-setup');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau Password tidak cocok dengan data pendaftaran lokal!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Masuk',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              child: const Text('🇮🇩', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Header
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F5B67).withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'lib/assets/logo-1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.storefront_rounded,
                    size: 42,
                    color: Color(0xFF0F5B67),
                  ),
                ),
              ),
              const Gap(16),
              const Text(
                'Mitra Digital POS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5B67),
                ),
              ),
              const Gap(4),
              Text(
                'Silakan masuk dengan akun terdaftar Anda',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Gap(28),

              // Main Login Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0F5B67).withValues(alpha: 0.3), width: 1.5),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Login Kasir',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Gap(20),

                      // Email Input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email Terdaftar',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),

                      // Password Input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const Gap(10),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            final user = AuthRepository.currentUser();
                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Petunjuk: Email terdaftar adalah "${user['email']}"'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(color: Color(0xFF0F5B67), fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      const Gap(16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5B67),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Masuk Akun',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              // Bottom Google Login Option
              Text(
                'Atau masuk langsung melalui',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Gap(14),
              GestureDetector(
                onTap: () => GoogleAccountPickerDialog.show(context, ref),
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                      height: 26,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'G',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(24),

              // Navigate to Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        color: Color(0xFF0F5B67),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
