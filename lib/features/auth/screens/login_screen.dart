import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Stream your favorite short dramas anytime, anywhere.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Email',
                hint: 'name@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Login',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: () {
                  ref
                      .read(authProvider.notifier)
                      .login(_emailController.text, _passwordController.text);
                },
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Center(
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: AppColors.primary,
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
        ),
      ),
    );
  }
}
