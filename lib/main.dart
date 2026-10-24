import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/local_database.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi SharedPreferences lokal sebelum UI dimuat
  await LocalDatabase.init();
  
  runApp(
    const ProviderScope(
      child: MitraPosApp(),
    ),
  );
}

class MitraPosApp extends StatelessWidget {
  const MitraPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mitra POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
