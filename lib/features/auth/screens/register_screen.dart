import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Join our community of drama lovers.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Name',
                hint: 'John Doe',
                controller: _nameController,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
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
                label: 'Register',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: () {
                  ref
                      .read(authProvider.notifier)
                      .register(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                      );
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
            ],
          ),
        ),
      ),
    );
  }
}
