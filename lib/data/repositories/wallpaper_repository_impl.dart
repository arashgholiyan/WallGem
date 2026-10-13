import 'dart:math';
import 'package:http/http.dart' as http;
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/i_wallpaper_repository.dart';
import '../datasources/alphacoders_source.dart';
import '../datasources/bing_wallpaper_source.dart';
import '../datasources/birdpaper_source.dart';
import '../datasources/curated_wallpaper_source.dart';
import '../datasources/fourk_wallpapers_source.dart';
import '../datasources/picsum_source.dart';
import '../datasources/wallhaven_api_source.dart';
import '../datasources/wallpaperhub_source.dart';
import '../datasources/wallpaperscraft_source.dart';
import '../datasources/wallpaperswide_source.dart';
import '../datasources/windows_spotlight_source.dart';
import '../models/wallpaper_model.dart';

/// Aggregates multiple distinct wallpaper APIs and scraping feeds.
class WallpaperRepositoryImpl implements IWallpaperRepository {
  final WallhavenApiSource _wallhavenSource;
  final BingWallpaperSource _bingSource;
  final WallpapersWideSource _wideSource;
  final WallpapersCraftSource _craftSource;
  final AlphaCodersSource _alphaSource;
  final FourKWallpapersSource _fourKSource;
  final WallpaperHubSource _hubSource;
  final WindowsSpotlightSource _spotlightSource;
  final BirdpaperSource _birdSource;
  final PicsumSource _picsumSource;

  WallpaperRepositoryImpl({
    http.Client? client,
    WallhavenApiSource? wallhavenSource,
    BingWallpaperSource? bingSource,
    WallpapersWideSource? wideSource,
    WallpapersCraftSource? craftSource,
    AlphaCodersSource? alphaSource,
    FourKWallpapersSource? fourKSource,
    WallpaperHubSource? hubSource,
    WindowsSpotlightSource? spotlightSource,
    BirdpaperSource? birdSource,
    PicsumSource? picsumSource,
  }) : _wallhavenSource = wallhavenSource ?? WallhavenApiSource(client: client),
       _bingSource = bingSource ?? BingWallpaperSource(client: client),
       _wideSource = wideSource ?? WallpapersWideSource(client: client),
       _craftSource = craftSource ?? WallpapersCraftSource(client: client),
       _alphaSource = alphaSource ?? AlphaCodersSource(client: client),
       _fourKSource = fourKSource ?? FourKWallpapersSource(client: client),
       _hubSource = hubSource ?? WallpaperHubSource(client: client),
       _spotlightSource =
           spotlightSource ?? WindowsSpotlightSource(client: client),
       _birdSource = birdSource ?? BirdpaperSource(client: client),
       _picsumSource = picsumSource ?? PicsumSource(client: client);

  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    String source = 'All Sources',
    int page = 1,
  }) async {
    final aggregated = <WallpaperModel>[];

    // Check if user requested a specific source platform
    final selected = source.trim().toLowerCase();

    if (selected == 'wallpaperswide') {
      aggregated.addAll(
        await _wideSource.fetchWallpapers(category: category, page: page),
      );
    } else if (selected == 'wallpaperscraft') {
      aggregated.addAll(
        await _craftSource.fetchWallpapers(category: category, page: page),
      );
    } else if (selected == 'alphacoders') {
      aggregated.addAll(
        await _alphaSource.fetchWallpapers(category: category, page: page),
      );
    } else if (selected == '4k wallpapers') {
      aggregated.addAll(
        await _fourKSource.fetchWallpapers(category: category, page: page),
      );
    } else if (selected == 'wallpaperhub') {
      aggregated.addAll(await _hubSource.fetchWallpapers(page: page));
    } else if (selected == 'windows spotlight') {
      aggregated.addAll(await _spotlightSource.fetchDailySpotlight());
    } else if (selected == 'bing daily') {
      aggregated.addAll(await _bingSource.fetchDailyWallpapers());
    } else if (selected == 'birdpaper 4k') {
      aggregated.addAll(
        await _birdSource.fetchWallpapers(category: category, page: page),
      );
    } else if (selected == 'picsum photos') {
      aggregated.addAll(await _picsumSource.fetchWallpapers(page: page));
    } else if (selected == 'wallhaven') {
      aggregated.addAll(
        await _wallhavenSource.fetchWallpapers(category: category, page: page),
      );
    } else {
      // "All Sources" (Smart Shuffle Mix)
      final futures = <Future<List<WallpaperModel>>>[
        _wallhavenSource.fetchWallpapers(category: category, page: page),
        _wideSource.fetchWallpapers(category: category, page: page),
        _craftSource.fetchWallpapers(category: category, page: page),
        _fourKSource.fetchWallpapers(category: category, page: page),
        _alphaSource.fetchWallpapers(category: category, page: page),
        if (page == 1) ...[
          _bingSource.fetchDailyWallpapers(),
          _spotlightSource.fetchDailySpotlight(),
          _hubSource.fetchWallpapers(page: 1),
          _birdSource.fetchWallpapers(category: category, page: 1),
          _picsumSource.fetchWallpapers(page: 1),
        ],
      ];

      final remoteLists = await Future.wait(futures);
      for (final list in remoteLists) {
        aggregated.addAll(list);
      }
    }

    // Curated offline fallback ensures the swipe deck is never empty
    if (aggregated.isEmpty) {
      final curated = CuratedWallpaperSource.getCuratedWallpapers();
      if (category == 'All') {
        aggregated.addAll(curated);
      } else {
        aggregated.addAll(
          curated.where(
            (w) =>
                w.category.toLowerCase().contains(category.toLowerCase()) ||
                w.title.toLowerCase().contains(category.toLowerCase()),
          ),
        );
      }
    }

    // Deduplicate items by ID
    final seenIds = <String>{};
    final uniqueModels = <WallpaperModel>[];
    for (final item in aggregated) {
      if (!seenIds.contains(item.id)) {
        seenIds.add(item.id);
        uniqueModels.add(item);
      }
    }

    // Shuffle with seeded random for smooth variety
    uniqueModels.shuffle(
      Random(page * 79 + category.hashCode + source.hashCode),
    );

    return uniqueModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query) async {
    final results = await _wallhavenSource.fetchWallpapers(
      category: query,
      page: 1,
    );
    return results.map((m) => m.toEntity()).toList();
  }
}
