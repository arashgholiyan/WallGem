import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/favorite_wallpaper.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/wallpaper_action_provider.dart';
import '../../providers/wallpaper_deck_provider.dart';
import '../preview/wallpaper_preview_dialog.dart';
import 'favorite_card.dart';

/// Full gallery grid view displaying the user's persisted favorites collection.
class FavoritesVaultView extends StatefulWidget {
  const FavoritesVaultView({super.key});

  @override
  State<FavoritesVaultView> createState() => _FavoritesVaultViewState();
}

class _FavoritesVaultViewState extends State<FavoritesVaultView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPreview(BuildContext context, FavoriteWallpaper wallpaper) {
    showDialog(
      context: context,
      builder: (ctx) => WallpaperPreviewDialog(
        wallpaper: wallpaper,
        onApply: () {
          context.read<WallpaperActionProvider>().applyAsWallpaper(wallpaper);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final actionProvider = context.read<WallpaperActionProvider>();
    final favorites = favProvider.filteredFavorites;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Raycast / Linear Command Bar Search & Filter Header
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xE6141826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _searchController.text.isNotEmpty
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          if (_searchController.text.isNotEmpty)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: _searchController.text.isNotEmpty
                                ? AppColors.cyan
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search favorites by title, artist, or tags...',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() {});
                                favProvider.setSearchKeyword(val);
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 17,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                favProvider.setSearchKeyword('');
                                setState(() {});
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                '⌘K',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏛️', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 7),
                        Text(
                          '${favorites.length} saved',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.categories.map((cat) {
                final isSelected = favProvider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0x99161B2A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFA5B4FC).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (_) => favProvider.setSelectedCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Main Content: Grid or Empty State
          Expanded(
            child: favorites.isEmpty
                ? _buildEmptyState(context, favProvider)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth >= 1200) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth >= 750) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        itemCount: favorites.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.76,
                        ),
                        itemBuilder: (context, index) {
                          final item = favorites[index];
                          return FavoriteCard(
                            wallpaper: item,
                            onTap: () => _showPreview(context, item),
                            onApply: () async {
                              final success = await actionProvider
                                  .applyAsWallpaper(item);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: success
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFF7F1D1D),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      success
                                          ? 'Applied "${item.title}" as desktop wallpaper!'
                                          : 'Failed to set wallpaper. Please check permissions.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            onRemove: () {
                              favProvider.removeFavorite(item.id);
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF1E293B),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  content: Text(
                                    'Removed "${item.title}" from Vault',
                                  ),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    textColor: AppColors.cyan,
                                    onPressed: () =>
                                        favProvider.addFavorite(item),
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            },
                            onSplit: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Multi-Monitor Split: Dual-display assets prepared in Pictures/WallGem/MultiMonitor',
                                  ),
                                  backgroundColor: Color(0xFF1E2235),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FavoritesProvider provider) {
    final hasAnyFavorites = provider.favorites.isNotEmpty;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xD9121624),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasAnyFavorites ? '🔍' : '🏛️',
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  hasAnyFavorites
                      ? 'No matching wallpapers'
                      : 'Your Vault is Empty',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    hasAnyFavorites
                        ? 'Try adjusting your search query or category filter.'
                        : 'Like or star wallpapers in the 3D Deck to preserve them in your offline vault.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    hasAnyFavorites
                        ? Icons.clear_all_rounded
                        : Icons.view_carousel_rounded,
                    size: 18,
                  ),
                  label: Text(
                    hasAnyFavorites ? 'Reset Filters' : 'Explore 3D Deck',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  onPressed: () {
                    if (hasAnyFavorites) {
                      _searchController.clear();
                      provider.setSearchKeyword('');
                      provider.setSelectedCategory('All');
                      setState(() {});
                    } else {
                      context.read<WallpaperDeckProvider>().setViewMode(
                        ViewMode.deck,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
