import 'package:flutter/material.dart';
import '../models/series_model.dart';
import '../../series/screens/series_detail_screen.dart';
import '../../../core/theme/app_colors.dart';

class SeriesCard extends StatelessWidget {
  final Series series;
  final int index;

  const SeriesCard({super.key, required this.series, required this.index});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(24),
      topRight: Radius.circular(index % 3 == 0 ? 60 : 24),
      bottomLeft: Radius.circular(index % 2 == 0 ? 24 : 60),
      bottomRight: const Radius.circular(24),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeriesDetailScreen(series: series),
          ),
        );
      },
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              // Thumbnail
              Positioned.fill(
                child: Image.network(
                  series.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.darkSurface,
                    child: const Icon(
                      Icons.movie_outlined,
                      color: Colors.white24,
                      size: 48,
                    ),
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Info
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      series.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${series.episodesCount} Episodes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
