import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Official Microsoft MSN Delivery feed for Windows 10/11 Spotlight lockscreen wallpapers.
class WindowsSpotlightSource {
  final http.Client _client;

  WindowsSpotlightSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches the latest Windows Spotlight high-resolution images.
  Future<List<WallpaperModel>> fetchDailySpotlight() async {
    final uri = Uri.parse(
      'https://arc.msn.com/v3/Delivery/Placement?pid=209567&fmt=json&rafb=0&ua=WindowsShellClient%2F0&cdm=1&disphorzres=9999&dispvertres=9999&lo=80217&pl=en-US&lc=en-US&ctry=us',
    );

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final batch = decoded['batchItems'] as List<dynamic>? ?? [];
        return parseBatchItems(batch);
      }
    } catch (e) {
      debugPrint('WindowsSpotlightSource error: $e');
    }

    return const [];
  }

  /// Parses MSN delivery batch items.
  List<WallpaperModel> parseBatchItems(List<dynamic> batch) {
    final results = <WallpaperModel>[];

    for (var i = 0; i < batch.length; i++) {
      final itemMap = batch[i];
      if (itemMap is! Map<String, dynamic>) continue;

      final rawItem = itemMap['item'];
      if (rawItem is! String) continue;

      try {
        final parsed = json.decode(rawItem) as Map<String, dynamic>;
        final ad = parsed['ad'] as Map<String, dynamic>? ?? {};

        // Extract landscape image URL
        String? fullUrl;
        String resolution = '1920x1200 (HD)';

        for (final key in [
          'image_fullscreen_003_landscape',
          'image_fullscreen_002_landscape',
          'image_fullscreen_001_landscape',
          'image_fullscreen_004_landscape',
        ]) {
          final imgObj = ad[key];
          if (imgObj is Map<String, dynamic> && imgObj['u'] != null) {
            fullUrl = imgObj['u'].toString();
            final w = imgObj['w']?.toString() ?? '1920';
            final h = imgObj['h']?.toString() ?? '1200';
            resolution = '${w}x$h';
            break;
          }
        }

        if (fullUrl == null || fullUrl.isEmpty) continue;

        // Title from title_text or destination search query
        final titleText =
            ad['title_text']?['tx']?.toString() ??
            ad['copyright_text']?['tx']?.toString() ??
            'Windows Spotlight #$i';

        results.add(
          WallpaperModel(
            id: 'spotlight_$i',
            title: titleText,
            author: 'Microsoft Windows Spotlight',
            sourceName: 'Windows Spotlight',
            thumbUrl: fullUrl,
            fullUrl: fullUrl,
            resolution: resolution,
            ratio: '16:10',
            category: 'Landmarks & Scenery',
            colors: const [],
          ),
        );
      } catch (e) {
        debugPrint('Error parsing spotlight item: $e');
      }
    }

    return results;
  }
}
