import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Scrapes high-resolution 4K/8K wallpapers from AlphaCoders.com.
class AlphaCodersSource {
  final http.Client _client;

  AlphaCodersSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches 4K/8K wallpapers from AlphaCoders.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final catSlug = _mapCategory(category);
    final uri = Uri.parse('https://alphacoders.com/$catSlug?page=$page');

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        return parseHtml(res.body);
      }
    } catch (e) {
      debugPrint('AlphaCodersSource fetch error: $e');
    }

    return const [];
  }

  /// Parses AlphaCoders page HTML into WallpaperModels.
  List<WallpaperModel> parseHtml(String html) {
    final results = <WallpaperModel>[];

    // AlphaCoders embeds wallpaper metadata cleanly in schema.org meta tags:
    // <meta itemprop="contentUrl" content="https://images5.alphacoders.com/141/1415928.png">
    final contentRegex = RegExp(
      r'<meta\s+itemprop="contentUrl"\s+content="([^"]+)"',
      caseSensitive: false,
    );
    final thumbRegex = RegExp(
      r'<meta\s+itemprop="thumbnailUrl"\s+content="([^"]+)"',
      caseSensitive: false,
    );

    final contentMatches = contentRegex.allMatches(html).toList();
    final thumbMatches = thumbRegex.allMatches(html).toList();

    for (var i = 0; i < contentMatches.length; i++) {
      final fullUrl = contentMatches[i].group(1);
      if (fullUrl == null || fullUrl.isEmpty) continue;

      final thumbUrl =
          (i < thumbMatches.length && thumbMatches[i].group(1) != null)
          ? thumbMatches[i].group(1)!
          : fullUrl;

      // Extract filename / id from URL e.g. 1415928
      final uri = Uri.tryParse(fullUrl);
      final rawName = uri?.pathSegments.isNotEmpty == true
          ? uri!.pathSegments.last.split('.').first
          : 'alpha_$i';

      results.add(
        WallpaperModel(
          id: 'alpha_$rawName',
          title: 'AlphaCoders #$rawName',
          author: 'AlphaCoders Community',
          sourceName: 'alphacoders.com',
          thumbUrl: thumbUrl,
          fullUrl: fullUrl,
          resolution: '3840x2160 (4K/8K)',
          ratio: '16:9',
          category: 'Digital & Concept Art',
          colors: const [],
        ),
      );
    }

    return results;
  }

  String _mapCategory(String category) {
    final cat = category.toLowerCase();
    if (cat == 'gaming' || cat == 'games') return 'video-game-wallpapers';
    if (cat == 'anime') return 'anime-wallpapers';
    if (cat == 'landscape' || cat == 'nature') return 'nature-wallpapers';
    if (cat == 'cars' || cat == 'vehicles') return 'vehicle-wallpapers';
    if (cat == 'space' || cat == 'sci-fi' || cat == 'cyberpunk') {
      return 'sci-fi-wallpapers';
    }
    if (cat == 'fantasy') return 'fantasy-wallpapers';
    if (cat == 'movies') return 'movie-wallpapers';
    return 'newest-wallpapers';
  }
}
