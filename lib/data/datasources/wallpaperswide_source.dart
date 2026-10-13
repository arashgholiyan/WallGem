import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Scrapes and builds high-resolution 4K wallpapers from WallpapersWide.com.
class WallpapersWideSource {
  final http.Client _client;

  WallpapersWideSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches 4K/UHD wallpapers from WallpapersWide by category.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final path = _mapCategoryToPath(category, page);
    final uri = Uri.parse('https://wallpaperswide.com/$path');

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        return parseHtml(res.body);
      }
    } catch (e) {
      debugPrint('WallpapersWideSource fetch error: $e');
    }

    return const [];
  }

  /// Parses WallpapersWide thumbnail HTML into WallpaperModels with 4K download targets.
  List<WallpaperModel> parseHtml(String html) {
    final results = <WallpaperModel>[];
    // Regex matches thumbnail images on WallpapersWide:
    // e.g. <img src="https://hd.wallpaperswide.com/thumbs/epic_sunset-t1.jpg" alt="..." ...
    final regex = RegExp(
      r'src="https:\/\/hd\.wallpaperswide\.com\/thumbs\/([a-zA-Z0-9_\-]+)-t1\.jpg"(?:[^>]*alt="([^"]*)")?',
      caseSensitive: false,
    );

    for (final match in regex.allMatches(html)) {
      final slug = match.group(1);
      if (slug == null || slug.isEmpty) continue;

      final rawAlt = match.group(2) ?? '';
      // Clean title from alt text
      final title = rawAlt.isNotEmpty
          ? rawAlt.split('4K').first.split('UHD').first.trim()
          : slug.replaceAll('_', ' ');

      final thumbUrl = 'https://hd.wallpaperswide.com/thumbs/$slug-t1.jpg';
      final fullUrl =
          'https://wallpaperswide.com/download/$slug-wallpaper-3840x2160.jpg';

      results.add(
        WallpaperModel(
          id: 'wide_$slug',
          title: title.isEmpty ? slug.replaceAll('_', ' ') : title,
          author: 'WallpapersWide',
          sourceName: 'wallpaperswide.com',
          thumbUrl: thumbUrl,
          fullUrl: fullUrl,
          resolution: '3840x2160 (4K UHD)',
          ratio: '16:9',
          category: '4K Desktop',
          colors: const [],
        ),
      );
    }

    return results;
  }

  String _mapCategoryToPath(String category, int page) {
    final cat = category.toLowerCase();
    String base;
    if (cat == 'anime') {
      base = 'anime-desktop-wallpapers.html';
    } else if (cat == 'gaming' || cat == 'games') {
      base = 'games-desktop-wallpapers.html';
    } else if (cat == 'cars' || cat == 'vehicles') {
      base = 'cars-desktop-wallpapers.html';
    } else if (cat == 'landscape' || cat == 'nature') {
      base = 'nature-desktop-wallpapers.html';
    } else if (cat == 'space') {
      base = 'space-desktop-wallpapers.html';
    } else if (cat == 'city' || cat == 'architecture') {
      base = 'city-desktop-wallpapers.html';
    } else {
      base = '';
    }

    if (page > 1) {
      return base.isEmpty ? 'page/$page' : '$base/page/$page';
    }
    return base;
  }
}
