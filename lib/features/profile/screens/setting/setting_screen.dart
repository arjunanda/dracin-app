import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
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
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Switch between light and dark mode',
            trailing: Text(
              isDark ? 'Dark' : 'Light',
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
            title: 'Notifications',
            subtitle: 'Manage your app alerts',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'Choose your preferred language',
            trailing: const Text(
              'Bahasa',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {},
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),
          _buildSectionHeader(context, 'Support'),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Find answers to common questions',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'About Dracin',
            subtitle: 'App version, terms, and privacy',
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.5),
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
