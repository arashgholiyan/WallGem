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
          // Search & Filter Header
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Search favorites by title, artist, or tags...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (val) => favProvider.setSearchKeyword(val),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            favProvider.setSearchKeyword('');
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🏛️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${favorites.length} saved',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                    backgroundColor: const Color(0xFF161B2A),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
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
                            onApply: () =>
                                actionProvider.applyAsWallpaper(item),
                            onRemove: () => favProvider.removeFavorite(item.id),
                            onSplit: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Multi-Monitor Split: Dual-display assets prepared in Pictures/WallGem/MultiMonitor',
                                  ),
                                  backgroundColor: const Color(0xFF1E2235),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasAnyFavorites ? '🔍' : '🏛️',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 14),
          Text(
            hasAnyFavorites ? 'No matching wallpapers' : 'Your Vault is Empty',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasAnyFavorites
                ? 'Try adjusting your search query or category filter.'
                : 'Like or star wallpapers in the 3D Deck to preserve them in your offline vault.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(hasAnyFavorites ? Icons.clear_all : Icons.view_carousel),
            label: Text(
              hasAnyFavorites ? 'Reset Filters' : 'Explore 3D Deck',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (hasAnyFavorites) {
                _searchController.clear();
                provider.setSearchKeyword('');
                provider.setSelectedCategory('All');
              } else {
                context.read<WallpaperDeckProvider>().setViewMode(
                  ViewMode.deck,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
