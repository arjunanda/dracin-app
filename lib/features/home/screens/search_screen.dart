import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/series_model.dart';
import '../providers/series_provider.dart';
import '../../series/screens/series_shorts_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _searchHistory = [
    'The Silent Sea',
    'Squid Game',
    'All of Us Are Dead',
  ];

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

  @override
  Widget build(BuildContext context) {
    final seriesState = ref.watch(seriesProvider);
    final filteredSeries = seriesState.series.where((s) {
      return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background Blobs for consistency
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlurBlob(AppColors.accent.withOpacity(0.05), 200),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _buildInitialState()
                      : _buildSearchResults(filteredSeries),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    onSubmitted: (val) {
                      _addToHistory(val);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search dramas...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      prefixIcon: Icon(Icons.search, color: AppColors.accent),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    final trending = ['Romance', 'Action', 'Thriller', 'Comedy', 'Historical'];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Text(
          'Trending Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: trending.map((tag) => _buildTag(tag)).toList(),
        ),
        if (_searchHistory.isNotEmpty) ...[
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchHistory.clear();
                  });
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppColors.accent.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._searchHistory.map((query) => _buildHistoryItem(query)).toList(),
        ],
      ],
    );
  }

  Widget _buildSearchResults(List<Series> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final series = results[index];
        return _buildResultCard(series);
      },
    );
  }

  Widget _buildResultCard(Series series) {
    return GestureDetector(
      onTap: () {
        _addToHistory(series.title);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SeriesShortsScreen(
              seriesId: series.id,
              title: series.title,
              thumbnailUrl: series.thumbnailUrl,
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
                  image: NetworkImage(series.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            series.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            '${series.episodesCount} Episodes',
            style: TextStyle(
              color: AppColors.accent.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        setState(() {
          _searchQuery = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _searchController.text = title;
          setState(() {
            _searchQuery = title;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.history, color: Colors.white24, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white24, size: 18),
                onPressed: () {
                  setState(() {
                    _searchHistory.remove(title);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
