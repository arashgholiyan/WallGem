import '../entities/wallpaper.dart';

/// Abstract contract for fetching wallpapers from aggregated sources.
abstract class IWallpaperRepository {
  /// Fetches an aggregated and shuffled page of wallpapers for the specified [category].
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    int page = 1,
  });

  /// Searches wallpapers matching [query].
  Future<List<Wallpaper>> searchWallpapers(String query);
}
