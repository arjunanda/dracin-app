import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';

import '../../series/screens/series_shorts_screen.dart';
import '../providers/series_provider.dart';
import '../providers/category_provider.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;

  List<String> _getCategories(AppLanguage lang) {
    return [
      AppStrings.get('trending', lang),
      AppStrings.get('latest', lang),
      AppStrings.get('recommended', lang),
    ];
  }

  @override
  void initState() {
    super.initState();
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
    final lang = ref.watch(languageProvider);
    final categories = _getCategories(lang);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Blobs for Depth
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurBlob(AppColors.primary.withOpacity(0.1), 300),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: _buildBlurBlob(AppColors.accent.withOpacity(0.05), 250),
            ),
          ],

          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                floating: true,
                title: Image.asset(
                  'assets/logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 24),
                    ),
                  ),
                ],
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () => ref
                    .read(seriesProvider.notifier)
                    .getSeries(
                      refresh: true,
                      type: state.currentType,
                      categoryId: state.categoryId,
                    ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySelector(isDark, categories),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              ..._buildSelectedSection(context, state, lang),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark, List<String> staticCategories) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final allCategories = [
          ...staticCategories,
          ...categories.map((c) => c.name),
        ];

        return Container(
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              final categoryName = allCategories[index];

              return GestureDetector(
                onTap: () {
                  if (_selectedCategoryIndex == index) return;

                  setState(() {
                    _selectedCategoryIndex = index;
                  });

                  // Trigger API call based on selection
                  if (index < staticCategories.length) {
                    // It's a static type (Trending, Latest, etc)
                    String type = 'popular';
                    if (index == 1) type = 'newest';
                    if (index == 2) type = 'recommended';

                    ref
                        .read(seriesProvider.notifier)
                        .getSeries(refresh: true, type: type);
                  } else {
                    // It's a dynamic category from API
                    final categoryIndex = index - staticCategories.length;
                    final categoryId = categories[categoryIndex].id;

                    ref
                        .read(seriesProvider.notifier)
                        .getSeries(refresh: true, categoryId: categoryId);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.darkTextSecondary.withOpacity(0.8)
                                : AppColors.lightTextSecondary),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 66,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  List<Widget> _buildSelectedSection(
    BuildContext context,
    SeriesListState state,
    AppLanguage lang,
  ) {
    if (state.isLoading && state.series.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 400,
            child: Center(child: CupertinoActivityIndicator()),
          ),
        ),
      ];
    }

    if (!state.isLoading && state.series.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter_rounded,
                  size: 80,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('no_content_found', lang),
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final series = state.series;

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final s = series[index % series.length];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SeriesShortsScreen(
                      seriesId: s.id,
                      title: s.title,
                      bannerUrl: s.bannerUrl,
                      showBackButton: true,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          s.bannerUrl,
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
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.9),
                              ],
                              stops: const [0.4, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s.episodesCount ?? 0} Episodes',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
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
          }, childCount: series.length),
        ),
      ),
      if (ref.watch(seriesProvider).isLoading && series.isNotEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CupertinoActivityIndicator()),
          ),
        ),
    ];
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
