import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/comments_provider.dart';
import 'package:intl/intl.dart';

class CommentSection extends ConsumerStatefulWidget {
  final String seriesId;

  const CommentSection({super.key, required this.seriesId});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.seriesId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Comment Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts...',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    ref
                        .read(commentsProvider(widget.seriesId).notifier)
                        .postComment(_commentController.text);
                    _commentController.clear();
                  }
                },
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Comments List
        if (state.comments.isEmpty && !state.isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drama here yet...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Be the first to break the silence!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.comments.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.comments.length) {
                final comment = state.comments[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      comment.userName[0],
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(
                    comment.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.content),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().format(comment.createdAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
      ],
    );
  }
}
