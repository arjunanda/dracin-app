import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(seriesProvider);

    if (state.isLoading) return;

    final position = _scrollController.position;
    if (!position.hasPixels) return;

    if (!state.hasMore) return;

    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(seriesProvider.notifier).getSeries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          if (isDark) const _BackgroundBlobs(),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(isDark),
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
                child: _CategorySelector(
                  selectedIndex: _selectedCategoryIndex,
                  onCategoryChanged: (index, type, categoryId) {
                    setState(() => _selectedCategoryIndex = index);
                    ref
                        .read(seriesProvider.notifier)
                        .getSeries(
                          refresh: true,
                          type: type,
                          categoryId: categoryId,
                        );
                  },
                ),
              ),
              ..._buildSelectedSection(context, state, lang),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      title: Image.asset('assets/logo.png', height: 50, fit: BoxFit.contain),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            child: IconButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
              icon: const Icon(Icons.search_rounded, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectedSection(
    BuildContext context,
    SeriesListState state,
    AppLanguage lang,
  ) {
    if (state.isLoading && state.series.isEmpty) {
      return [
        const SliverFillRemaining(
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }

    if (!state.isLoading && state.series.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(lang: lang),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SeriesCard(series: state.series[index]),
            childCount: state.series.length,
          ),
        ),
      ),
      if (state.hasMore)
        SliverToBoxAdapter(
          child: Container(
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 20),
            child: state.isLoading
                ? const CupertinoActivityIndicator()
                : const SizedBox.shrink(),
          ),
        )
      else
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
    ];
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _BlurBlob(
              color: AppColors.primary.withOpacity(0.1),
              size: 300,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _BlurBlob(
              color: AppColors.accent.withOpacity(0.05),
              size: 250,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  final int selectedIndex;
  final void Function(int, String?, String?) onCategoryChanged;

  const _CategorySelector({
    required this.selectedIndex,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final staticCategories = [
      AppStrings.get('trending', lang),
      AppStrings.get('latest', lang),
      AppStrings.get('recommended', lang),
    ];

    return categoriesAsync.when(
      data: (categories) {
        final allNames = [
          ...staticCategories,
          ...categories.map((c) => c.name),
        ];
        return SizedBox(
          height: 66,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: allNames.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  if (isSelected) return;
                  String? type;
                  String? categoryId;
                  if (index < staticCategories.length) {
                    type = index == 0
                        ? 'popular'
                        : (index == 1 ? 'newest' : 'recommended');
                  } else {
                    categoryId = categories[index - staticCategories.length].id;
                  }
                  onCategoryChanged(index, type, categoryId);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    allNames[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final dynamic series;
  const _SeriesCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SeriesShortsScreen(
            seriesId: series.id,
            title: series.title,
            bannerUrl: series.bannerUrl,
            showBackButton: true,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: series.bannerUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                memCacheWidth: 400,
                placeholder: (context, url) => Container(
                  color: Colors.grey.withOpacity(0.1),
                  child: const Center(
                    child: CupertinoActivityIndicator(radius: 10),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey.shade900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38, // Height for exactly 2 lines of text
            child: Text(
              series.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.3, // Consistent line height
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${series.episodesCount ?? 0} Episodes',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLanguage lang;
  const _EmptyState({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
