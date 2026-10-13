import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';

/// Responsive, overflow-safe top navigation bar with platform source selector.
class HeaderBar extends StatelessWidget {
  final int likedCount;
  final String activeSource;
  final ValueChanged<String> onSelectSource;
  final VoidCallback onOpenFolder;

  const HeaderBar({
    super.key,
    required this.likedCount,
    required this.activeSource,
    required this.onSelectSource,
    required this.onOpenFolder,
  });

  String _getSourceEmoji(String source) {
    switch (source) {
      case 'WallpapersWide':
        return '🖼️';
      case 'WallpapersCraft':
        return '🎨';
      case 'AlphaCoders':
        return '⚔️';
      case '4K Wallpapers':
        return '🏎️';
      case 'WallpaperHub':
        return '💻';
      case 'Birdpaper 4K':
        return '🦅';
      case 'Wallhaven':
        return '💎';
      case 'Bing Daily':
        return '🌅';
      case 'Windows Spotlight':
        return '🪟';
      case 'Picsum Photos':
        return '📷';
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (likedCount / AppConstants.batchTarget).clamp(0.0, 1.0);

    return Container(
      key: AppKeys.headerBar,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xCC12151F),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & App Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x666366F1), blurRadius: 10),
                      ],
                    ),
                    child: const Center(
                      child: Text('💎', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Source Selector Dropdown
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: AppConstants.sources.contains(activeSource)
                        ? activeSource
                        : AppConstants.sources.first,
                    dropdownColor: const Color(0xFF1E2235),
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryLight,
                      size: 18,
                    ),
                    isDense: true,
                    items: AppConstants.sources.map((src) {
                      return DropdownMenuItem(
                        value: src,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getSourceEmoji(src),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              src,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onSelectSource(val);
                    },
                  ),
                ),
              ),

              // Batch Progress Bar & Folder Launcher
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: isCompact ? 50 : 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.like,
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$likedCount / ${AppConstants.batchTarget}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.like,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.folder_open_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'Open Wallpaper Folder',
                    onPressed: onOpenFolder,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
