import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/multi_monitor_splitter_service.dart';
import '../../../domain/entities/wallpaper.dart';
import '../palette/palette_export_modal.dart';

/// Fullscreen inspection lightbox for high-resolution wallpaper previews,
/// palette extraction, and multi-monitor panoramic display splitting.
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
    final isPanoramic = MultiMonitorSplitterService.isPanoramic(
      wallpaper.resolution,
      wallpaper.aspectRatio,
    );

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
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

            // Bottom Quick Bar with Actions
            Positioned(
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEE0B0F19),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        wallpaper.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Palette Exporter Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.palette_outlined, size: 16),
                        label: const Text(
                          'Export Palette',
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () =>
                            PaletteExportModal.show(context, wallpaper),
                      ),

                      if (isPanoramic) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.splitscreen, size: 16),
                          label: const Text(
                            'Dual Screens',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Panoramic wallpaper ready for dual-monitor bisection',
                                ),
                                backgroundColor: Color(0xFF1E2235),
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.star,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.wallpaper, size: 16),
                        label: const Text(
                          'Set Wallpaper',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
