import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Client and scraper for WallpapersCraft.com.
class WallpapersCraftSource {
  final http.Client _client;

  WallpapersCraftSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches high-resolution wallpapers from WallpapersCraft.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final catPath = _mapCategory(category);
    final urlStr = catPath.isEmpty
        ? (page == 1
              ? 'https://wallpaperscraft.com/'
              : 'https://wallpaperscraft.com/all/page$page')
        : (page == 1
              ? 'https://wallpaperscraft.com/catalog/$catPath'
              : 'https://wallpaperscraft.com/catalog/$catPath/page$page');

    final uri = Uri.parse(urlStr);

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        return parseHtml(res.body);
      }
    } catch (e) {
      debugPrint('WallpapersCraftSource fetch error: $e');
    }

    return const [];
  }

  /// Parses WallpapersCraft HTML for wallpapers.
  List<WallpaperModel> parseHtml(String html) {
    final results = <WallpaperModel>[];
    // Matches: <img class="wallpapers__image" src="https://images.wallpaperscraft.com/image/single/forest_trees_1725448_300x168.jpg" alt="Preview wallpaper forest..."
    final regex = RegExp(
      r'src="https:\/\/images\.wallpaperscraft\.com\/image\/single\/([a-zA-Z0-9_\-]+)_300x168\.jpg"(?:[^>]*alt="([^"]*)")?',
      caseSensitive: false,
    );

    for (final match in regex.allMatches(html)) {
      final slug = match.group(1);
      if (slug == null || slug.isEmpty) continue;

      final rawAlt = match.group(2) ?? '';
      final title = rawAlt.replaceFirst('Preview wallpaper', '').trim();

      final thumbUrl =
          'https://images.wallpaperscraft.com/image/single/${slug}_300x168.jpg';
      final fullUrl =
          'https://images.wallpaperscraft.com/image/single/${slug}_1920x1080.jpg';

      results.add(
        WallpaperModel(
          id: 'craft_$slug',
          title: title.isEmpty ? slug.replaceAll('_', ' ') : title,
          author: 'WallpapersCraft',
          sourceName: 'wallpaperscraft.com',
          thumbUrl: thumbUrl,
          fullUrl: fullUrl,
          resolution: '1920x1080 (FHD)',
          ratio: '16:9',
          category: 'Photography & Art',
          colors: const [],
        ),
      );
    }

    return results;
  }

  String _mapCategory(String category) {
    final cat = category.toLowerCase();
    if (cat == 'landscape' || cat == 'nature') return 'nature';
    if (cat == 'anime') return 'anime';
    if (cat == 'gaming' || cat == 'games') return 'games';
    if (cat == 'cars' || cat == 'vehicles') return 'cars';
    if (cat == 'space') return 'space';
    if (cat == 'city' || cat == 'architecture') return 'city';
    return '';
  }
}
