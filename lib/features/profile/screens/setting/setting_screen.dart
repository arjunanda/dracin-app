import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/language_provider.dart';

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
            icon: Icons.dark_mode_outlined,
            title: AppStrings.get('theme', lang),
            subtitle: lang == AppLanguage.id
                ? 'Ganti antara mode terang dan gelap'
                : 'Switch between light and dark mode',
            trailing: Text(
              isDark
                  ? (lang == AppLanguage.id ? 'Gelap' : 'Dark')
                  : (lang == AppLanguage.id ? 'Terang' : 'Light'),
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              final currentTheme = ref.read(themeProvider);
              ref
                  .read(themeProvider.notifier)
                  .state = currentTheme == ThemeMode.dark
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
            onTap: () {},
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
            onTap: () {
              ref.read(languageProvider.notifier).state = lang == AppLanguage.id
                  ? AppLanguage.en
                  : AppLanguage.id;
            },
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
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.get('about_dracin', lang),
            subtitle: lang == AppLanguage.id
                ? 'Versi aplikasi, ketentuan, dan privasi'
                : 'App version, terms, and privacy',
            onTap: () {},
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
