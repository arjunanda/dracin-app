import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/series_provider.dart';
import '../../home/widgets/series_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For simplicity, we filter the already loaded series.
    // In a real app, this would be a separate API call /api/me/watchlist.
    final state = ref.watch(seriesProvider);
    final watchlist = state.series.where((s) => s.isLoved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: watchlist.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 24),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some dramas you love!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final series = watchlist[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SeriesCard(series: series, index: index),
                );
              },
            ),
    );
  }
}
