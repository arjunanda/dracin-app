import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/for_you_screen.dart';
import '../../watchlist/screens/watchlist_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';

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
    // If Profile tab (index 3) is tapped, navigate to login
    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      setState(() {
        _currentIndex = index;
        // If switching to FYP, generate a new key to force reload
        if (index == 1) {
          _fypKey = UniqueKey();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // Or another icon for "For You"
            label: 'For You',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'WatchList',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
