import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_shortcuts.dart';
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
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onContinue();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
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
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 20,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Dismiss',
              onPressed: onContinue,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppConstants.batchTarget} ultra-high resolution 4K wallpapers have been collected for your ${PlatformShortcuts.slideshowPlatformLabel}.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: batch.take(AppConstants.batchTarget).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: item.thumbUrl,
                          width: 104,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF1E2235),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF1E2235),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
      ),
    );
  }
}
