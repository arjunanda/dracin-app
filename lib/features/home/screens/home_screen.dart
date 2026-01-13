import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../series/screens/series_episodes_screen.dart';
import '../../series/screens/series_shorts_screen.dart';
import '../providers/series_provider.dart';
import '../models/series_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Keep infinite scroll behavior, but getSeries returns stubbed data.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(seriesProvider.notifier).getSeries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'Discover',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: AppColors.accent,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 28),
              ),
              const SizedBox(width: 8),
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () =>
                ref.read(seriesProvider.notifier).getSeries(refresh: true),
          ), // Top banner-only layout: show a single large banner for the first series
          ..._buildSections(context, state.series),
        ],
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, List<Series> series) {
    if (series.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    final sections = [
      'Trending Now',
      'New Releases',
      'Recommended for You',
      'Top Rated',
    ];
    List<Widget> slivers = [];

    for (var i = 0; i < sections.length; i++) {
      final sectionTitle = sections[i];
      // For demo purposes, we shuffle or rotate the list to make sections look different
      // In a real app, we would filter or fetch different data
      final sectionSeries = List<Series>.from(series)..shuffle();
      final displaySeries = sectionSeries
          .take(6)
          .toList(); // Show top 6 for each section

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    fontSize: 20,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final s = displaySeries[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SeriesShortsScreen(seriesId: s.id, title: s.title),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            s.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, st) =>
                                Container(color: Colors.grey.shade900),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Text(
                            s.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: displaySeries.length),
          ),
        ),
      );
    }

    // Add some bottom padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 40)));

    return slivers;
  }
}
