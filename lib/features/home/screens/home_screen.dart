import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/widgets/custom_skeleton.dart';
import '../providers/series_provider.dart';
import '../widgets/series_card.dart';

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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'For You',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 24),
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
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < state.series.length) {
                  final series = state.series[index];
                  // Create uneven layout by varying margins or styles
                  final isEven = index % 2 == 0;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 24.0,
                      left: isEven ? 0 : 20,
                      right: isEven ? 20 : 0,
                    ),
                    child: SeriesCard(series: series, index: index),
                  );
                }

                if (state.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CustomSkeleton(
                        width: double.infinity,
                        height: 200,
                        borderRadius: 24,
                      ),
                    ),
                  );
                }

                return const SizedBox(height: 100);
              }, childCount: state.series.length + (state.hasMore ? 1 : 0)),
            ),
          ),
        ],
      ),
    );
  }
}
