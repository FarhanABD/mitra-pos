import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../product/data/product_repository.dart';
import '../../profile/data/sales_repository.dart';
import '../data/auth_repository.dart';
import 'google_account_picker_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralController = TextEditingController();

  bool _agreeTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus menyetujui Syarat & Ketentuan untuk melanjutkan.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final success = await AuthRepository.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: '+62${_phoneController.text.trim()}',
        referralCode: _referralController.text.trim().isEmpty ? null : _referralController.text.trim(),
      );

      if (success && mounted) {
        // Refresh Riverpod state for clean new user
        ref.read(salesProvider.notifier).loadTransactions();
        ref.read(productListProvider.notifier).loadProducts();
        ref.read(categoryListProvider.notifier).loadCategories();

        context.go('/shop-setup');
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
          'Daftar',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(10),
              // Main Register Card
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
                        'Register',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Gap(24),

                      // Full Name Input
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: 'Nama Lengkap',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),

                      // Email Input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
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
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),

                      // Phone Input
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Text('🇮🇩', style: TextStyle(fontSize: 18)),
                                const Gap(4),
                                const Text(
                                  '+62',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Nomor Telepon',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nomor telepon tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),

                      // Referral Code Input
                      TextFormField(
                        controller: _referralController,
                        decoration: const InputDecoration(
                          hintText: 'Kode Referral (jika ada)',
                        ),
                      ),
                      const Gap(16),

                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeTerms,
                            activeColor: const Color(0xFF0F5B67),
                            onChanged: (val) {
                              setState(() {
                                _agreeTerms = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Dengan mendaftar, kamu sudah menyetujui '),
                                    TextSpan(
                                      text: 'Syarat Ketentuan & Kebijakan Privasi',
                                      style: TextStyle(
                                        color: Color(0xFF0F5B67),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5B67),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Buat Akun',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(32),

              // Bottom Sign Up Options
              Text(
                'Atau daftar langsung melalui',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Gap(16),
              GestureDetector(
                onTap: () => GoogleAccountPickerDialog.show(context, ref),
                child: Container(
                  height: 56,
                  width: 56,
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

              // Already have an account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Masuk Sekarang',
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
