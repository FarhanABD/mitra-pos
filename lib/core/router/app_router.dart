import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/shop/data/shop_repository.dart';
import '../../features/shop/presentation/shop_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/product/presentation/product_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isSplash = state.uri.toString() == '/splash';
    if (isSplash) {
      // Allow splash screen to display initial animation & timer
      return null;
    }

    final isRegistering = state.uri.toString() == '/register';
    final isLoggingIn = state.uri.toString() == '/login';
    final isSettingUpShop = state.uri.toString() == '/shop-setup';

    // 1. Check if user profile is registered
    final hasUser = AuthRepository.hasUser();
    if (!hasUser) {
      // Direct them to login screen if not registered
      return (isRegistering || isLoggingIn) ? null : '/login';
    }

    // 2. Check if shop details are filled
    final hasShop = ShopRepository.hasShop();
    if (!hasShop) {
      // If registered but shop details are missing, force setup
      return isSettingUpShop ? null : '/shop-setup';
    }

    // 3. Prevent going back to login/register/shop-setup if already configured
    if (isRegistering || isLoggingIn || isSettingUpShop) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/shop-setup',
      name: 'shop-setup',
      builder: (context, state) => const ShopSetupScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => const PosScreen(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Halaman tidak ditemukan: ${state.error}'),
    ),
  ),
);
