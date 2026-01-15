import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/language_provider.dart';

final notificationSettingsProvider = StateProvider<Map<String, bool>>(
  (ref) => {'new_episodes': true, 'promotions': false, 'system': true},
);

class NotificationSettingScreen extends ConsumerWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('notification_settings', lang),
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
          const SizedBox(height: 16),
          _buildSwitchTile(
            ref,
            title: AppStrings.get('new_episodes', lang),
            subtitle: AppStrings.get('new_episodes_desc', lang),
            value: settings['new_episodes'] ?? false,
            onChanged: (val) => _updateSetting(ref, 'new_episodes', val),
            isDark: isDark,
          ),
          _buildSwitchTile(
            ref,
            title: AppStrings.get('promotions', lang),
            subtitle: AppStrings.get('promotions_desc', lang),
            value: settings['promotions'] ?? false,
            onChanged: (val) => _updateSetting(ref, 'promotions', val),
            isDark: isDark,
          ),
          _buildSwitchTile(
            ref,
            title: AppStrings.get('system_notif', lang),
            subtitle: AppStrings.get('system_notif_desc', lang),
            value: settings['system'] ?? false,
            onChanged: (val) => _updateSetting(ref, 'system', val),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _updateSetting(WidgetRef ref, String key, bool value) {
    final current = ref.read(notificationSettingsProvider);
    ref.read(notificationSettingsProvider.notifier).state = {
      ...current,
      key: value,
    };
  }

  Widget _buildSwitchTile(
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha((0.05 * 255).toInt())
            : Colors.black.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withAlpha(
              (0.6 * 255).toInt(),
            ),
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        activeTrackColor: AppColors.accent.withAlpha((0.3 * 255).toInt()),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withAlpha((0.2 * 255).toInt()),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
