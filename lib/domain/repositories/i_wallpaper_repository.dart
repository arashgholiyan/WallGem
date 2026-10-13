import '../entities/wallpaper.dart';

/// Abstract contract for fetching wallpapers from aggregated sources.
abstract class IWallpaperRepository {
  /// Fetches an aggregated or source-filtered page of wallpapers.
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    String source = 'All Sources',
    int page = 1,
  });

  /// Searches wallpapers matching [query].
  Future<List<Wallpaper>> searchWallpapers(String query);
}
