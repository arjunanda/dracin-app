import 'package:flutter/material.dart';
import '../../series/screens/series_shorts_screen.dart';

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SeriesShortsScreen(
      seriesId: 'fyp',
      title: 'For You',
      thumbnailUrl: 'https://picsum.photos/seed/fyp/800/1200',
      showBackButton: false,
    );
  }
}
