import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Client for the open Picsum Photos (Unsplash-backed 5K photo library).
class PicsumSource {
  final http.Client _client;

  PicsumSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches ultra-high-resolution real-world photography.
  Future<List<WallpaperModel>> fetchWallpapers({int page = 1}) async {
    final uri = Uri.parse('https://picsum.photos/v2/list?page=$page&limit=20');

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as List<dynamic>;
        return parseItems(decoded);
      }
    } catch (e) {
      debugPrint('PicsumSource error: $e');
    }

    return const [];
  }

  /// Parses Picsum items.
  List<WallpaperModel> parseItems(List<dynamic> items) {
    final results = <WallpaperModel>[];

    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;

      final id = raw['id']?.toString() ?? '';
      final author = raw['author']?.toString() ?? 'Unsplash Contributor';
      final w = raw['width']?.toString() ?? '5000';
      final h = raw['height']?.toString() ?? '3333';
      final downloadUrl = raw['download_url']?.toString() ?? '';
      final thumbUrl = 'https://picsum.photos/id/$id/600/400';

      if (id.isNotEmpty && downloadUrl.isNotEmpty) {
        results.add(
          WallpaperModel(
            id: 'picsum_$id',
            title: '$author - Photo #$id',
            author: author,
            sourceName: 'picsum.photos (Unsplash)',
            thumbUrl: thumbUrl,
            fullUrl: downloadUrl,
            resolution: '${w}x$h (5K Studio)',
            ratio: '16:10',
            category: 'Studio Photography',
            colors: const [],
          ),
        );
      }
    }

    return results;
  }
}
