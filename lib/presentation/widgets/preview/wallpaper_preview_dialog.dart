import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';

/// Fullscreen inspection lightbox for high-resolution wallpaper previews.
class WallpaperPreviewDialog extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback onApply;

  const WallpaperPreviewDialog({
    super.key,
    required this.wallpaper,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image Container
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: wallpaper.fullUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => CachedNetworkImage(
                imageUrl: wallpaper.thumbUrl,
                fit: BoxFit.contain,
              ),
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: wallpaper.thumbUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Bottom Quick Bar with Apply button
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wallpaper.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.star,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.wallpaper, size: 18),
                    label: const Text(
                      'Set as Wallpaper',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onApply();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
