import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../models/series_model.dart';
import '../providers/series_provider.dart';
import '../providers/category_provider.dart';
import '../../series/screens/series_shorts_screen.dart';
import '../../../core/network/ad_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeCategoryId;

  final List<String> _searchHistory = [
    'The Silent Sea',
    'Squid Game',
    'All of Us Are Dead',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adServiceProvider).showTimedAd(ref);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToHistory(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) _searchHistory.removeLast();
    });
  }

  void _applyCategoryFilter(String label, String categoryId) {
    setState(() {
      _searchQuery = label;
      _activeCategoryId = categoryId;
      _searchController.text = label;
    });
    // USE the dedicated search provider!
    ref
        .read(searchSeriesProvider.notifier)
        .getSeries(refresh: true, categoryId: categoryId);
    _addToHistory(label);
  }

  void _clearSelection() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _activeCategoryId = null;
    });
    // Reset to trending on search provider
    ref
        .read(searchSeriesProvider.notifier)
        .getSeries(refresh: true, type: 'popular');
  }

  @override
  Widget build(BuildContext context) {
    // WATCH the dedicated search provider!
    final seriesState = ref.watch(searchSeriesProvider);
    final lang = ref.watch(languageProvider);

    List<Series> resultsToDisplay;
    if (_activeCategoryId != null) {
      // If category is active, bypass local filter and show API data
      resultsToDisplay = seriesState.series;
    } else {
      // Local text search on current data
      resultsToDisplay = seriesState.series.where((s) {
        if (_searchQuery.isEmpty) return true;
        return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    final isSearching = _searchQuery.isNotEmpty || _activeCategoryId != null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
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
          SafeArea(
            child: Column(
              children: [
                _buildHeader(lang, isSearching),
                Expanded(
                  child: !isSearching
                      ? _buildInitialState(lang)
                      : _buildSearchResultsGrid(
                          resultsToDisplay,
                          seriesState.isLoading,
                          lang,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLanguage lang, bool isSearching) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _activeCategoryId = null;
                  });
                },
                onSubmitted: (val) {
                  if (val.isNotEmpty) _addToHistory(val);
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: lang == AppLanguage.id
                      ? 'Cari drama...'
                      : 'Search dramas...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white54,
                            size: 22,
                          ),
                          onPressed: _clearSelection,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(AppLanguage lang) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              lang == AppLanguage.id
                  ? 'Kategori Populer'
                  : 'Popular Categories',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        categoriesAsync.when(
          data: (categories) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories
                .map((cat) => _buildTag(cat.name, cat.id))
                .toList(),
          ),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
        if (_searchHistory.isNotEmpty) ...[
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang == AppLanguage.id
                    ? 'Pencarian Terakhir'
                    : 'Recent Searches',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _searchHistory.clear()),
                child: Text(
                  lang == AppLanguage.id ? 'Hapus' : 'Clear',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          ..._searchHistory.map((q) => _buildHistoryItem(q)),
        ],
      ],
    );
  }

  Widget _buildSearchResultsGrid(
    List<Series> results,
    bool isLoading,
    AppLanguage lang,
  ) {
    if (results.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              lang == AppLanguage.id
                  ? 'Tidak ada hasil ditemukan'
                  : 'No results found',
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CupertinoActivityIndicator(),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) => _buildDramaCard(results[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDramaCard(Series s) {
    return GestureDetector(
      onTap: () {
        _addToHistory(s.title);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(s.bannerUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${s.episodesCount ?? 0} Episodes',
            style: const TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, String id) {
    return GestureDetector(
      onTap: () => _applyCategoryFilter(label, id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.white24, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        _searchController.text = title;
        setState(() => _searchQuery = title);
      },
    );
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
