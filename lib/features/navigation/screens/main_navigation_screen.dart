import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/for_you_screen.dart';
import '../../watchlist/screens/watchlist_screen.dart';
import '../../profile/screens/profile_screen.dart';

import '../providers/navigation_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  Key _fypKey = UniqueKey();

  final List<Widget> _screens = [
    const HomeScreen(),
    const SizedBox.shrink(), // Placeholder for FYP
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: currentIndex == 1
          ? ForYouScreen(key: _fypKey)
          : _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).state = index;
          if (index == 1) {
            setState(() {
              _fypKey = UniqueKey();
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppStrings.get('home', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: AppStrings.get('for_you', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark),
            label: AppStrings.get('watchlist', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppStrings.get('profile', lang),
          ),
        ],
      ),
    );
  }
}
