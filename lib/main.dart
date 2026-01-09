import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Dracin App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
