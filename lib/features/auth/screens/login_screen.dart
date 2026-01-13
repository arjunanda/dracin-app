import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App Logo or Icon can go here
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Masuk untuk melanjutkan menonton drama favorit Anda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 48),

              // Social Login Buttons
              _buildSocialButton(
                label: 'Lanjutkan dengan Google',
                icon: Icons.g_mobiledata,
                color: isDark ? Colors.white : Colors.black,
                textColor: isDark ? Colors.black : Colors.white,
                onPressed: () {
                  // Implement Google Login
                },
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                label: 'Lanjutkan dengan Facebook',
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                onPressed: () {
                  // Implement Facebook Login
                },
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                label: 'Lanjutkan dengan TikTok',
                icon: Icons.music_note, // Representative icon for TikTok
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  // Implement TikTok Login
                },
              ),

              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const Spacer(),

              Text(
                'Dengan masuk, Anda menyetujui Ketentuan Layanan dan Kebijakan Privasi kami.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          .withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor, size: 28),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    );
  }
}
