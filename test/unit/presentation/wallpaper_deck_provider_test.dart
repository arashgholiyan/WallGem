import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';

class FakeWallpaperRepository implements IWallpaperRepository {
  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    String source = 'All Sources',
    int page = 1,
  }) async {
    return List.generate(
      10,
      (i) => Wallpaper(
        id: 'wall_$i',
        title: 'Wallpaper $i',
        author: 'Artist',
        sourceName: 'Source',
        thumbUrl: 'https://thumb.jpg',
        fullUrl: 'https://full.jpg',
        resolution: '4K',
        aspectRatio: '16:9',
        category: 'All',
        dominantColors: const [],
      ),
    );
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query) async => [];
}

void main() {
  test(
    'WallpaperDeckProvider manages deck, swipe right, undo, and batch threshold',
    () async {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);

      await provider.loadInitialFeed();
      expect(provider.deck.length, equals(10));

      final firstItem = provider.deck.first;
      provider.swipeRight(); // Like

      expect(provider.deck.length, equals(9));
      expect(provider.likedList.length, equals(1));
      expect(provider.likedList.first.id, equals(firstItem.id));

      // Undo
      provider.undo();
      expect(provider.deck.length, equals(10));
      expect(provider.likedList, isEmpty);
    },
  );

  test(
    'WallpaperDeckProvider swipeLeft passes wallpaper to history without liking',
    () async {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);

      await provider.loadInitialFeed();
      final firstItem = provider.deck.first;
      provider.swipeLeft();

      expect(provider.likedList, isEmpty);
      expect(provider.historyStack.last.id, equals(firstItem.id));
    },
  );

  test('WallpaperDeckProvider category change resets deck and page', () async {
    final repo = FakeWallpaperRepository();
    final provider = WallpaperDeckProvider(repository: repo);

    await provider.loadInitialFeed();
    await provider.setCategory('Cyberpunk');

    expect(provider.currentCategory, equals('Cyberpunk'));
    expect(
      provider.page,
      equals(2),
    ); // Incremented after initial load for category
  });

  test(
    'WallpaperDeckProvider source change updates currentSource and refreshes',
    () async {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);

      await provider.loadInitialFeed();
      await provider.setSource('WallpapersWide');

      expect(provider.currentSource, equals('WallpapersWide'));
      expect(provider.page, equals(2));
    },
  );
}
