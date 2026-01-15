import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/for_you_screen.dart';
import '../../watchlist/screens/watchlist_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  Key _fypKey = UniqueKey();

  final List<Widget> _screens = [
    const HomeScreen(),
    const SizedBox.shrink(), // Placeholder for FYP
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      // If switching to FYP, generate a new key to force reload
      if (index == 1) {
        _fypKey = UniqueKey();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: _currentIndex == 1
          ? ForYouScreen(key: _fypKey)
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
