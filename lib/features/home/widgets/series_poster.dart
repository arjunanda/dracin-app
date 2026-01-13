import 'package:flutter/material.dart';
import '../models/series_model.dart';
import '../../series/screens/series_detail_screen.dart';

class SeriesPoster extends StatelessWidget {
  final Series series;
  final double width;
  final double height;

  const SeriesPoster({super.key, required this.series, this.width = 140, this.height = 220});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SeriesDetailScreen(series: series)),
      ),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                series.thumbnailUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: width,
                  height: height,
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.movie_outlined, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              series.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${series.episodesCount} eps',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
