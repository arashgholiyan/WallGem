import 'dart:math';
import 'package:http/http.dart' as http;
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/i_wallpaper_repository.dart';
import '../datasources/bing_wallpaper_source.dart';
import '../datasources/curated_wallpaper_source.dart';
import '../datasources/wallhaven_api_source.dart';
import '../models/wallpaper_model.dart';

/// Aggregates multiple wallpaper APIs and curated offline sources.
class WallpaperRepositoryImpl implements IWallpaperRepository {
  final WallhavenApiSource _wallhavenSource;
  final BingWallpaperSource _bingSource;

  WallpaperRepositoryImpl({
    http.Client? client,
    WallhavenApiSource? wallhavenSource,
    BingWallpaperSource? bingSource,
  }) : _wallhavenSource = wallhavenSource ?? WallhavenApiSource(client: client),
       _bingSource = bingSource ?? BingWallpaperSource(client: client);

  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final aggregated = <WallpaperModel>[];

    // Concurrently fetch remote sources
    final futures = <Future<List<WallpaperModel>>>[
      _wallhavenSource.fetchWallpapers(category: category, page: page),
      if (page == 1 &&
          (category == 'All' || category.toLowerCase() == 'landscape'))
        _bingSource.fetchDailyWallpapers(),
    ];

    final remoteLists = await Future.wait(futures);
    for (final list in remoteLists) {
      aggregated.addAll(list);
    }

    // Always append curated fallback catalog to ensure no empty deck
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

    // Deduplicate by ID
    final seenIds = <String>{};
    final uniqueModels = <WallpaperModel>[];
    for (final item in aggregated) {
      if (!seenIds.contains(item.id)) {
        seenIds.add(item.id);
        uniqueModels.add(item);
      }
    }

    // Shuffle with seeded random for fresh variety per page
    uniqueModels.shuffle(Random(page * 79 + category.hashCode));

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
