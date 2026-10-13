import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';

/// Modal dialog presented when user completes liking a batch of 5 wallpapers.
class BatchCompleteDialog extends StatelessWidget {
  final List<Wallpaper> batch;
  final VoidCallback onOpenFolder;
  final VoidCallback onContinue;

  const BatchCompleteDialog({
    super.key,
    required this.batch,
    required this.onOpenFolder,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Row(
        children: [
          Text('🎉 ', style: TextStyle(fontSize: 26)),
          Text(
            'Batch Completed!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppConstants.batchTarget} ultra-high resolution 4K wallpapers have been collected for your Windows Slideshow.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: batch.take(AppConstants.batchTarget).length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = batch[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbUrl,
                    width: 104,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.folder_open, size: 18),
          label: const Text('Open Folder'),
          onPressed: onOpenFolder,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.like,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onContinue,
          child: const Text(
            'Swipe More',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
