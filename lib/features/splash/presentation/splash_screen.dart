import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../shop/data/shop_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Start timer for splash screen redirection
    Timer(const Duration(milliseconds: 2800), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final hasUser = AuthRepository.hasUser();
    if (!hasUser) {
      context.go('/register');
      return;
    }

    final hasShop = ShopRepository.hasShop();
    if (!hasShop) {
      context.go('/shop-setup');
      return;
    }

    context.go('/');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F5B67), // Teal Gelap
              Color(0xFF136F7D),
              Color(0xFF45A1B2), // Teal Muda
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Logo & App Title Container
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Logo Container
                      Container(
                        width: 130,
                        height: 130,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/assets/logo-1.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.storefront_rounded,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const Gap(28),
                      // Title Text
                      Text(
                        'Mitra Digital POS',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(8),
                      // Subtitle
                      Text(
                        'Sistem Kasir Digital Terpercaya untuk UMKM',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Loading Spinner
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                ),
              ),
              const Gap(24),

              // Footer Branding
              Text(
                'Powered by Mitra Digital',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.8,
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
