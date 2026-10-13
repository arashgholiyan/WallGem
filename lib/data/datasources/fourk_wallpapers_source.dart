import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Scrapes 4K UHD wallpapers from 4kwallpapers.com.
class FourKWallpapersSource {
  final http.Client _client;

  FourKWallpapersSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches 4K wallpapers from 4kwallpapers.com.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final catSlug = _mapCategory(category);
    final urlStr = catSlug.isEmpty
        ? (page == 1
              ? 'https://4kwallpapers.com/'
              : 'https://4kwallpapers.com/random-wallpapers/')
        : (page == 1
              ? 'https://4kwallpapers.com/$catSlug/'
              : 'https://4kwallpapers.com/$catSlug/?page=$page');

    final uri = Uri.parse(urlStr);

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        return parseHtml(res.body);
      }
    } catch (e) {
      debugPrint('FourKWallpapersSource fetch error: $e');
    }

    return const [];
  }

  /// Parses 4kwallpapers.com HTML.
  List<WallpaperModel> parseHtml(String html) {
    final results = <WallpaperModel>[];

    // Matches: <img itemprop="thumbnail" src="/images/walls/thumbs/27323.jpg" ... alt="Desert, Rocks..."
    final regex = RegExp(
      r'src="\/images\/walls\/thumbs\/([0-9]+)\.jpg"(?:[^>]*alt="([^"]*)")?',
      caseSensitive: false,
    );

    // Also look for link slugs: href="/abstract/translucent-floral-27323.html"
    final linkRegex = RegExp(
      r'href="\/[a-z0-9_\-]+\/([a-z0-9_\-]+)-([0-9]+)\.html"',
      caseSensitive: false,
    );

    final slugMap = <String, String>{};
    for (final match in linkRegex.allMatches(html)) {
      final slug = match.group(1);
      final id = match.group(2);
      if (id != null && slug != null) {
        slugMap[id] = slug;
      }
    }

    for (final match in regex.allMatches(html)) {
      final id = match.group(1);
      if (id == null || id.isEmpty) continue;

      final rawAlt = match.group(2) ?? '';
      final title = rawAlt.isNotEmpty
          ? rawAlt.split(',').first.trim()
          : '4K Wallpaper #$id';

      final thumbUrl =
          'https://4kwallpapers.com/images/walls/thumbs_2t/$id.jpg';
      final slug = slugMap[id];
      final fullUrl = slug != null
          ? 'https://4kwallpapers.com/images/wallpapers/$slug-3840x2160-$id.jpg'
          : 'https://4kwallpapers.com/images/walls/thumbs_2t/$id.jpg';

      results.add(
        WallpaperModel(
          id: '4kwall_$id',
          title: title,
          author: '4KWallpapers.com',
          sourceName: '4kwallpapers.com',
          thumbUrl: thumbUrl,
          fullUrl: fullUrl,
          resolution: '3840x2160 (4K UHD)',
          ratio: '16:9',
          category: '4K Ultra HD',
          colors: const [],
        ),
      );
    }

    return results;
  }

  String _mapCategory(String category) {
    final cat = category.toLowerCase();
    if (cat == 'cars' || cat == 'vehicles') return 'cars';
    if (cat == 'landscape' || cat == 'nature') return 'nature';
    if (cat == 'gaming' || cat == 'games') return 'games';
    if (cat == 'anime') return 'anime';
    if (cat == 'space') return 'space';
    if (cat == 'minimal') return 'minimal';
    if (cat == 'oled dark' || cat == 'dark') return 'dark';
    return '';
  }
}
