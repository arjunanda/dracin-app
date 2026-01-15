import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/language_provider.dart';
import '../about/about_screen.dart';
import './notification_setting_screen.dart';
import '../help/help_center_screen.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

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
          AppStrings.get('settings', lang),
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
        children: [
          _buildSectionHeader(context, AppStrings.get('preferences', lang)),
          _buildSettingTile(
            context,
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            title: AppStrings.get('theme', lang),
            subtitle: lang == AppLanguage.id
                ? 'Ganti antara mode terang dan gelap'
                : 'Switch between light and dark mode',
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).state = val
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
              activeColor: AppColors.accent,
            ),
            onTap: () {
              ref.read(themeProvider.notifier).state = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_none_outlined,
            title: AppStrings.get('notifications', lang),
            subtitle: lang == AppLanguage.id
                ? 'Atur peringatan aplikasi Anda'
                : 'Manage your app alerts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.language_outlined,
            title: AppStrings.get('language', lang),
            subtitle: lang == AppLanguage.id
                ? 'Pilih bahasa pilihan Anda'
                : 'Choose your preferred language',
            trailing: Text(
              lang == AppLanguage.id ? 'Bahasa Indonesia' : 'English',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _showLanguageSelector(context, ref, lang),
          ),

          const Divider(height: 32, indent: 16, endIndent: 16),
          _buildSectionHeader(context, AppStrings.get('support', lang)),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: AppStrings.get('help_center', lang),
            subtitle: lang == AppLanguage.id
                ? 'Cari jawaban untuk pertanyaan umum'
                : 'Find answers to common questions',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.get('about_dracin', lang),
            subtitle: lang == AppLanguage.id
                ? 'Versi aplikasi, ketentuan, dan privasi'
                : 'App version, terms, and privacy',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '${AppStrings.get('version', lang)} 1.0.0',
              style: TextStyle(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    AppLanguage currentLang,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final lang = ref.watch(languageProvider);
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('select_language', lang),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLanguageOption(
                    context,
                    ref,
                    title: AppStrings.get('indonesian', lang),
                    language: AppLanguage.id,
                    isSelected: lang == AppLanguage.id,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    title: AppStrings.get('english', lang),
                    language: AppLanguage.en,
                    isSelected: lang == AppLanguage.en,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required AppLanguage language,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        ref.read(languageProvider.notifier).state = language;
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.grey.withAlpha((0.2 * 255).toInt()),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.accent
                    : (isDark ? Colors.white : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
