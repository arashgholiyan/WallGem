import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/multi_monitor_splitter_service.dart';
import '../../../domain/entities/favorite_wallpaper.dart';
import '../palette/palette_export_modal.dart';

/// Card widget representing an individual favorited wallpaper in the Vault grid.
class FavoriteCard extends StatefulWidget {
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
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  bool _isCardHovered = false;

  @override
  Widget build(BuildContext context) {
    final wallpaper = widget.wallpaper;
    final isPanoramic = MultiMonitorSplitterService.isPanoramic(
      wallpaper.resolution,
      wallpaper.aspectRatio,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedScale(
        scale: _isCardHovered ? 1.025 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF141827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isCardHovered
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.09),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isCardHovered ? 0.5 : 0.28,
                ),
                blurRadius: _isCardHovered ? 20 : 10,
                offset: Offset(0, _isCardHovered ? 8 : 4),
              ),
              if (_isCardHovered)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Image Container
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: CachedNetworkImage(
                          imageUrl: wallpaper.thumbUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          memCacheWidth: 600,
                          fadeInDuration: const Duration(milliseconds: 200),
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
                      ),

                      // Category & Panoramic Badges
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    wallpaper.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isPanoramic) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
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
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x666366F1),
                                      blurRadius: 8,
                                    ),
                                  ],
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF131726),
                    border: Border(
                      top: BorderSide(color: Color(0x1AFFFFFF), width: 0.8),
                    ),
                  ),
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
                          letterSpacing: -0.2,
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
                          _CardActionButton(
                            icon: Icons.palette_outlined,
                            color: AppColors.primaryLight,
                            tooltip: 'Export Palette (Pywal/CSS)',
                            onPressed: () =>
                                PaletteExportModal.show(context, wallpaper),
                          ),

                          if (isPanoramic)
                            _CardActionButton(
                              icon: Icons.splitscreen,
                              color: AppColors.secondary,
                              tooltip: 'Dual-Monitor Split (Left/Right)',
                              onPressed: widget.onSplit,
                            ),

                          // Set Wallpaper
                          _CardActionButton(
                            icon: Icons.wallpaper,
                            color: AppColors.star,
                            tooltip: 'Set as Desktop Wallpaper',
                            onPressed: widget.onApply,
                          ),

                          // Remove Favorite
                          _CardActionButton(
                            icon: Icons.delete_outline,
                            color: AppColors.pass,
                            tooltip: 'Remove from Vault',
                            onPressed: widget.onRemove,
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
      ),
    );
  }
}

class _CardActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _CardActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_CardActionButton> createState() => _CardActionButtonState();
}

class _CardActionButtonState extends State<_CardActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered
              ? widget.color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(widget.icon, size: 16),
          color: _isHovered
              ? widget.color
              : widget.color.withValues(alpha: 0.85),
          tooltip: widget.tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
