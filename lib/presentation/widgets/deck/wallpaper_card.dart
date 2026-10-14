import 'dart:ui';
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
    final accentColor = wallpaper.dominantColors.isNotEmpty
        ? wallpaper.dominantColors.first
        : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 50,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 0,
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.88),
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.8,
                      ),
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
                                letterSpacing: -0.2,
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
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
