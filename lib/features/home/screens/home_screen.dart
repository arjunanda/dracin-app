import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../series/screens/series_shorts_screen.dart';
import '../providers/series_provider.dart';
import 'search_screen.dart';
import '../models/series_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Trending Now',
    'Terbaru',
    'Rekomendasi',
    'Top Rated',
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'KiSah',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                icon: const Icon(Icons.search, size: 28),
              ),
              const SizedBox(width: 8),
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () =>
                ref.read(seriesProvider.notifier).getSeries(refresh: true),
          ),
          SliverToBoxAdapter(child: _buildCategorySelector(isDark)),
          ..._buildSelectedSection(context, state.series),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSelectedSection(
    BuildContext context,
    List<Series> series,
  ) {
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

    // For demo purposes, we shuffle or rotate the list to make sections look different
    // In a real app, we would filter or fetch different data
    final sectionSeries = List<Series>.from(series)..shuffle();
    final displaySeries = sectionSeries
        .toList(); // Show all for the selected category

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final s = displaySeries[index % displaySeries.length];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeriesShortsScreen(
                      seriesId: s.id,
                      title: s.title,
                      thumbnailUrl: s.thumbnailUrl,
                      showBackButton: true,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
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
      const SliverToBoxAdapter(child: SizedBox(height: 40)),
    ];
  }
}
