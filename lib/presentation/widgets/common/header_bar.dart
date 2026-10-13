import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/wallpaper_deck_provider.dart';

/// Responsive, overflow-safe top navigation bar with view mode switcher,
/// platform source selector, Day/Night sun cycle, and slideshow timer.
class HeaderBar extends StatelessWidget {
  final int likedCount;
  final String activeSource;
  final ValueChanged<String> onSelectSource;
  final VoidCallback onOpenFolder;
  final ViewMode activeViewMode;
  final ValueChanged<ViewMode>? onSelectViewMode;
  final int favoritesCount;
  final bool isDayNightEnabled;
  final VoidCallback? onToggleDayNight;
  final Duration? autoCycleInterval;
  final ValueChanged<Duration?>? onSelectAutoCycleInterval;

  const HeaderBar({
    super.key,
    required this.likedCount,
    required this.activeSource,
    required this.onSelectSource,
    required this.onOpenFolder,
    this.activeViewMode = ViewMode.deck,
    this.onSelectViewMode,
    this.favoritesCount = 0,
    this.isDayNightEnabled = false,
    this.onToggleDayNight,
    this.autoCycleInterval,
    this.onSelectAutoCycleInterval,
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

  Widget _buildViewSegment(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
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
          final isCompact = constraints.maxWidth < 950;
          final isUltraCompact = constraints.maxWidth < 650;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Left: Logo & View Switcher
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(color: Color(0x666366F1), blurRadius: 8),
                      ],
                    ),
                    child: const Center(
                      child: Text('💎', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  if (!isUltraCompact) ...[
                    const SizedBox(width: 8),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                  const SizedBox(width: 14),

                  // View Switcher (Deck vs Vault)
                  Container(
                    height: 32,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B2A),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewSegment(
                          '🃏 Deck',
                          activeViewMode == ViewMode.deck,
                          () => onSelectViewMode?.call(ViewMode.deck),
                        ),
                        const SizedBox(width: 2),
                        _buildViewSegment(
                          '🏛️ Vault ($favoritesCount)',
                          activeViewMode == ViewMode.vault,
                          () => onSelectViewMode?.call(ViewMode.vault),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Center: Day/Night Sun Cycle & Auto-Cycler Timer
              if (!isCompact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day/Night Toggle Button
                    IconButton(
                      icon: Text(
                        isDayNightEnabled ? '☀️' : '🌙',
                        style: const TextStyle(fontSize: 16),
                      ),
                      tooltip: isDayNightEnabled
                          ? 'Sun Cycle Active (Syncing with Day/Night)'
                          : 'Sun Cycle Off (Tap to sync dynamic themes)',
                      onPressed: onToggleDayNight,
                    ),
                    const SizedBox(width: 4),

                    // Slideshow Timer Dropdown
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Duration?>(
                          value: autoCycleInterval,
                          dropdownColor: const Color(0xFF1E2235),
                          borderRadius: BorderRadius.circular(12),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryLight,
                            size: 16,
                          ),
                          isDense: true,
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                '⏱️ Timer: Off',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Duration(minutes: 15),
                              child: Text(
                                '⏱️ Cycle: 15m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Duration(minutes: 30),
                              child: Text(
                                '⏱️ Cycle: 30m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Duration(hours: 1),
                              child: Text(
                                '⏱️ Cycle: 1h',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Duration(hours: 4),
                              child: Text(
                                '⏱️ Cycle: 4h',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            onSelectAutoCycleInterval?.call(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

              // Right: Source Selector Dropdown & Batch Counter
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
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
                          size: 16,
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
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  src,
                                  style: const TextStyle(
                                    fontSize: 11,
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
                  const SizedBox(width: 8),

                  // Batch Progress & Folder
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: isUltraCompact ? 35 : 55,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.like,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$likedCount / ${AppConstants.batchTarget}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.like,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(
                      Icons.folder_open_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    tooltip: 'Open Wallpaper Folder',
                    onPressed: onOpenFolder,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ),
);
  }
}
