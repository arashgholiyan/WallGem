import '../entities/wallpaper.dart';
import '../entities/favorite_wallpaper.dart';

/// Contract for managing user favorites and persistence.
abstract class IFavoritesRepository {
  /// Loads all saved favorites from persistence.
  Future<List<FavoriteWallpaper>> loadFavorites();

  /// Saves or updates a favorite wallpaper.
  Future<void> saveFavorite(Wallpaper wallpaper, {String? localPath});

  /// Removes a favorite wallpaper by ID.
  Future<void> removeFavorite(String id);

  /// Checks if a wallpaper ID is currently marked as favorite.
  Future<bool> isFavorite(String id);
}
