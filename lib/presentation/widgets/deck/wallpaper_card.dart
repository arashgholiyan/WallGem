import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import 'card_badge.dart';

/// Card presentation rendering image, badges, title, author, and color dots.
class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // High-Resolution Background Wallpaper Image with Progressive Thumbnail Placeholder
          RepaintBoundary(
            child: CachedNetworkImage(
              imageUrl: wallpaper.fullUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              memCacheWidth: 1920,
              fadeInDuration: const Duration(milliseconds: 250),
              placeholder: (context, url) => CachedNetworkImage(
                imageUrl: wallpaper.thumbUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                memCacheWidth: 800,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF141722),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textMuted,
                      size: 36,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF141722),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textMuted,
                      size: 36,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: wallpaper.thumbUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF141722),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top Badges (Resolution & Source)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                CardBadge(
                  icon: Icons.high_quality_rounded,
                  label: wallpaper.resolution,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 8),
                CardBadge(
                  icon: Icons.public,
                  label: wallpaper.sourceName,
                  color: AppColors.secondary,
                  backgroundColor: const Color(0xCC181028),
                ),
              ],
            ),
          ),

          // Bottom Title, Author and Color Palette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wallpaper.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wallpaper.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (wallpaper.dominantColors.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: wallpaper.dominantColors
                          .map(
                            (c) => Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38),
                              ),
                            ),
                          )
                          .toList(),
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
