import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Client for publicly available Bing Daily Wallpaper feeds.
class BingWallpaperSource {
  final http.Client _client;

  BingWallpaperSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches the latest 8 daily high-resolution wallpapers from Bing.
  Future<List<WallpaperModel>> fetchDailyWallpapers() async {
    final uri = Uri.parse(
      'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=en-US',
    );

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final images = decoded['images'] as List<dynamic>? ?? [];

        return images
            .map(
              (item) =>
                  WallpaperModel.fromBingJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('BingWallpaperSource error: $e');
    }

    return const [];
  }
}
