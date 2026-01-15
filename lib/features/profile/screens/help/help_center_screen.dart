import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/language_provider.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('help_center', lang),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.accent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              AppStrings.get('help_center_desc', lang),
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withAlpha(
                  (0.6 * 255).toInt(),
                ),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            context,
            title: AppStrings.get('faq_account_title', lang),
            subtitle: AppStrings.get('faq_account_desc', lang),
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          _buildHelpCard(
            context,
            title: AppStrings.get('faq_billing_title', lang),
            subtitle: AppStrings.get('faq_billing_desc', lang),
            icon: Icons.payments_outlined,
            isDark: isDark,
          ),
          _buildHelpCard(
            context,
            title: AppStrings.get('faq_streaming_title', lang),
            subtitle: AppStrings.get('faq_streaming_desc', lang),
            icon: Icons.high_quality_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withAlpha((0.7 * 255).toInt()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.contact_support_rounded,
                  color: Colors.black,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  lang == AppLanguage.id
                      ? 'Masih butuh bantuan?'
                      : 'Still need help?',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lang == AppLanguage.id
                      ? 'Tim dukungan kami siap membantu Anda 24/7'
                      : 'Our support team is here for you 24/7',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withAlpha((0.7 * 255).toInt()),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: AppColors.accent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    lang == AppLanguage.id ? 'Hubungi Kami' : 'Contact Us',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha((0.05 * 255).toInt())
            : Colors.black.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withAlpha(
                (0.5 * 255).toInt(),
              ),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.accent, size: 20),
        onTap: () {},
      ),
    );
  }
}
