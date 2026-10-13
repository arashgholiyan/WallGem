import 'package:flutter/material.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/favorite_wallpaper.dart';
import '../../domain/repositories/i_favorites_repository.dart';

/// Presentation state controller managing the user's saved Favorites Vault,
/// keyword searches, and category filtering.
class FavoritesProvider extends ChangeNotifier {
  final IFavoritesRepository _repository;

  List<FavoriteWallpaper> _favorites = [];
  String _searchKeyword = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  FavoritesProvider({required IFavoritesRepository repository})
    : _repository = repository;

  List<FavoriteWallpaper> get favorites => List.unmodifiable(_favorites);
  String get searchKeyword => _searchKeyword;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  /// Returns the subset of favorites matching both category filter and search keyword.
  List<FavoriteWallpaper> get filteredFavorites {
    return _favorites.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      if (!matchesCategory) return false;

      if (_searchKeyword.trim().isEmpty) return true;

      final query = _searchKeyword.trim().toLowerCase();
      return item.title.toLowerCase().contains(query) ||
          item.author.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.sourceName.toLowerCase().contains(query);
    }).toList();
  }

  /// Sets the active keyword query for searching saved favorites.
  void setSearchKeyword(String query) {
    _searchKeyword = query;
    notifyListeners();
  }

  /// Sets the active category filter for saved favorites.
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Loads all saved favorites from persistence.
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _repository.loadFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a wallpaper to favorites and updates persistent storage.
  Future<void> addFavorite(Wallpaper wallpaper, {String? localPath}) async {
    await _repository.saveFavorite(wallpaper, localPath: localPath);
    _favorites.removeWhere((f) => f.id == wallpaper.id);
    _favorites.insert(
      0,
      FavoriteWallpaper.fromWallpaper(wallpaper, localFilePath: localPath),
    );
    notifyListeners();
  }

  /// Removes a wallpaper by ID from favorites and persistent storage.
  Future<void> removeFavorite(String id) async {
    await _repository.removeFavorite(id);
    _favorites.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  /// Toggles favorite status for a given wallpaper.
  Future<void> toggleFavorite(Wallpaper wallpaper, {String? localPath}) async {
    if (isFavorite(wallpaper.id)) {
      await removeFavorite(wallpaper.id);
    } else {
      await addFavorite(wallpaper, localPath: localPath);
    }
  }

  /// Checks if a wallpaper ID is currently present in favorites.
  bool isFavorite(String id) {
    return _favorites.any((f) => f.id == id);
  }
}
