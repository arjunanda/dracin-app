import 'package:flutter/material.dart';
import '../../series/screens/series_shorts_screen.dart';

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeriesShortsScreen(
      seriesId: 'fyp',
      title: 'For You',
      showBackButton: false,
    );
  }
}
