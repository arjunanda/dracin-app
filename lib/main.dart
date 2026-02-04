import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'core/services/admob_service.dart';
import 'core/services/payment_service.dart';
import 'core/utils/route_utils.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize AdMob in background - DON'T await it here to speed up launch
  AdMobService.initialize();

  // Initialize Payment Service
  PaymentService().initialize();

  // Keep screen active
  WakelockPlus.enable();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Kisah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}
