import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/entities/favorite_wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_favorites_repository.dart';
import 'package:wall_gem/presentation/providers/favorites_provider.dart';

class FakeFavoritesRepository implements IFavoritesRepository {
  final List<FavoriteWallpaper> _storage = [];

  @override
  Future<List<FavoriteWallpaper>> loadFavorites() async {
    return List.from(_storage);
  }

  @override
  Future<void> saveFavorite(Wallpaper wallpaper, {String? localPath}) async {
    _storage.removeWhere((f) => f.id == wallpaper.id);
    _storage.insert(
      0,
      FavoriteWallpaper.fromWallpaper(wallpaper, localFilePath: localPath),
    );
  }

  @override
  Future<void> removeFavorite(String id) async {
    _storage.removeWhere((f) => f.id == id);
  }

  @override
  Future<bool> isFavorite(String id) async {
    return _storage.any((f) => f.id == id);
  }
}

void main() {
  late FakeFavoritesRepository repository;
  late FavoritesProvider provider;

  final wall1 = Wallpaper(
    id: 'fav-1',
    title: 'Neon Cyberpunk Samurai',
    author: 'Akira',
    sourceName: 'Curated',
    thumbUrl: 'https://thumb1.jpg',
    fullUrl: 'https://full1.jpg',
    resolution: '3840x2160',
    aspectRatio: '16:9',
    category: 'Cyberpunk',
    dominantColors: const [Color(0xFF6366F1)],
  );

  final wall2 = Wallpaper(
    id: 'fav-2',
    title: 'Mountain Sunrise Aurora',
    author: 'Elena',
    sourceName: 'Curated',
    thumbUrl: 'https://thumb2.jpg',
    fullUrl: 'https://full2.jpg',
    resolution: '5120x1440',
    aspectRatio: '32:9',
    category: 'Landscape',
    dominantColors: const [Color(0xFF10B981)],
  );

  setUp(() {
    repository = FakeFavoritesRepository();
    provider = FavoritesProvider(repository: repository);
  });

  test('loadFavorites loads items from repository into state', () async {
    await repository.saveFavorite(wall1);
    await provider.loadFavorites();

    expect(provider.favorites.length, 1);
    expect(provider.favorites.first.id, 'fav-1');
  });

  test(
    'addFavorite and removeFavorite update state and notify listeners',
    () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.addFavorite(wall1);
      expect(provider.isFavorite('fav-1'), isTrue);
      expect(provider.favorites.length, 1);
      expect(notifyCount, greaterThanOrEqualTo(1));

      await provider.removeFavorite('fav-1');
      expect(provider.isFavorite('fav-1'), isFalse);
      expect(provider.favorites, isEmpty);
    },
  );

  test('toggleFavorite toggles presence cleanly', () async {
    await provider.toggleFavorite(wall1);
    expect(provider.isFavorite('fav-1'), isTrue);

    await provider.toggleFavorite(wall1);
    expect(provider.isFavorite('fav-1'), isFalse);
  });

  test('filteredFavorites correctly filters by keyword and category', () async {
    await provider.addFavorite(wall1);
    await provider.addFavorite(wall2);

    expect(provider.filteredFavorites.length, 2);

    // Search by title keyword
    provider.setSearchKeyword('Samurai');
    expect(provider.filteredFavorites.length, 1);
    expect(provider.filteredFavorites.first.id, 'fav-1');

    // Search by author keyword
    provider.setSearchKeyword('Elena');
    expect(provider.filteredFavorites.length, 1);
    expect(provider.filteredFavorites.first.id, 'fav-2');

    // Reset search, test category filter
    provider.setSearchKeyword('');
    provider.setSelectedCategory('Landscape');
    expect(provider.filteredFavorites.length, 1);
    expect(provider.filteredFavorites.first.id, 'fav-2');

    provider.setSelectedCategory('All');
    expect(provider.filteredFavorites.length, 2);
  });
}
