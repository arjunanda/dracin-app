import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/screens/main_navigation_screen.dart';
import 'core/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdMobService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Dracin App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Default to dark for the Imperial Dark experience
      themeMode: ThemeMode.dark,
      home: const MainNavigationScreen(),
    );
  }
}
