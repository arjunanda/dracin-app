import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.accent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: const Center(
        child: Text('Profile Content Coming Soon'),
      ),
    );
  }
}
