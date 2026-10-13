import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/multi_monitor_splitter_service.dart';
import '../../../domain/entities/favorite_wallpaper.dart';
import '../palette/palette_export_modal.dart';

/// Card widget representing an individual favorited wallpaper in the Vault grid.
class FavoriteCard extends StatelessWidget {
  final FavoriteWallpaper wallpaper;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final VoidCallback? onSplit;
  final VoidCallback? onTap;

  const FavoriteCard({
    super.key,
    required this.wallpaper,
    required this.onApply,
    required this.onRemove,
    this.onSplit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPanoramic = MultiMonitorSplitterService.isPanoramic(
      wallpaper.resolution,
      wallpaper.aspectRatio,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image Container
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: wallpaper.thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: const Color(0xFF1E2235)),
                    errorWidget: (_, _, _) => Container(
                      color: const Color(0xFF1E2235),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Category & Panoramic Badges
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            wallpaper.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isPanoramic) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '🖥️ 21:9+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details and Action Toolbar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallpaper.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${wallpaper.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Palette Button
                      IconButton(
                        icon: const Icon(Icons.palette_outlined, size: 18),
                        color: AppColors.primaryLight,
                        tooltip: 'Export Palette (Pywal/CSS)',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            PaletteExportModal.show(context, wallpaper),
                      ),

                      if (isPanoramic)
                        IconButton(
                          icon: const Icon(Icons.splitscreen, size: 18),
                          color: AppColors.secondary,
                          tooltip: 'Dual-Monitor Split (Left/Right)',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onSplit,
                        ),

                      // Set Wallpaper
                      IconButton(
                        icon: const Icon(Icons.wallpaper, size: 18),
                        color: AppColors.star,
                        tooltip: 'Set as Desktop Wallpaper',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onApply,
                      ),

                      // Remove Favorite
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: AppColors.pass,
                        tooltip: 'Remove from Vault',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
