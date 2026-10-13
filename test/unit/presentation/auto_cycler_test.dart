import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';

class FakeWallpaperRepository implements IWallpaperRepository {
  String lastFetchedCategory = 'All';

  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    String source = 'All Sources',
    int page = 1,
  }) async {
    lastFetchedCategory = category;
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
        category: category,
        dominantColors: const [],
      ),
    );
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query) async => [];
}

void main() {
  test(
    'WallpaperDeckProvider manages ViewMode switching between Deck and Vault',
    () {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);

      expect(provider.viewMode, ViewMode.deck);
      provider.setViewMode(ViewMode.vault);
      expect(provider.viewMode, ViewMode.vault);
      provider.setViewMode(ViewMode.deck);
      expect(provider.viewMode, ViewMode.deck);
    },
  );

  test(
    'WallpaperDeckProvider toggles DayNightMode and recommends category',
    () async {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);

      expect(provider.isDayNightModeEnabled, isFalse);
      await provider.toggleDayNightMode();
      expect(provider.isDayNightModeEnabled, isTrue);
      expect(provider.currentCategory, anyOf('Landscape', 'OLED Dark'));

      await provider.toggleDayNightMode();
      expect(provider.isDayNightModeEnabled, isFalse);
    },
  );

  test(
    'WallpaperDeckProvider manages autoCycleInterval and triggers callback',
    () async {
      final repo = FakeWallpaperRepository();
      final provider = WallpaperDeckProvider(repository: repo);
      await provider.loadInitialFeed();

      expect(provider.autoCycleInterval, isNull);

      int triggerCount = 0;
      provider.setAutoCycleInterval(
        const Duration(milliseconds: 50),
        onCycle: () => triggerCount++,
      );
      expect(provider.autoCycleInterval, const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 130));
      expect(triggerCount, greaterThanOrEqualTo(2));

      provider.setAutoCycleInterval(null);
      expect(provider.autoCycleInterval, isNull);
      final countAfterCancel = triggerCount;
      await Future.delayed(const Duration(milliseconds: 80));
      expect(triggerCount, equals(countAfterCancel));

      provider.dispose();
    },
  );
}
