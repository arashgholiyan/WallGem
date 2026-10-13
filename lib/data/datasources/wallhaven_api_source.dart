import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Official Wallhaven v1 REST API client.
class WallhavenApiSource {
  final http.Client _client;

  WallhavenApiSource({http.Client? client}) : _client = client ?? http.Client();

  /// Queries Wallhaven v1 API for 4K/UHD wallpapers.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'purity': '100', // SFW only
      'atleast': '1920x1080',
      'sorting': page == 1 ? 'toplist' : 'random',
      'page': page.toString(),
    };

    if (category != 'All') {
      if (category.toLowerCase() == 'anime') {
        queryParams['categories'] = '010'; // Anime only
      } else if (category.toLowerCase() == 'landscape') {
        queryParams['q'] = 'landscape nature';
      } else if (category.toLowerCase() == 'cyberpunk') {
        queryParams['q'] = 'cyberpunk neon city';
      } else if (category.toLowerCase() == 'space') {
        queryParams['q'] = 'space nebula galaxy';
      } else if (category.toLowerCase() == 'oled dark') {
        queryParams['q'] = 'dark black minimal';
      } else {
        queryParams['q'] = category.toLowerCase();
      }
    }

    final uri = Uri.https('wallhaven.cc', '/api/v1/search', queryParams);

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final data = decoded['data'] as List<dynamic>? ?? [];

        return data
            .map(
              (item) => WallpaperModel.fromWallhavenJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('WallhavenApiSource fetch error: $e');
    }

    return const [];
  }
}
