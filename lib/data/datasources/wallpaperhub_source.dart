import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Official REST API client for WallpaperHub.app (Surface, Xbox, Windows 11 & Minimal).
class WallpaperHubSource {
  final http.Client _client;

  WallpaperHubSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches daily wallpapers from WallpaperHub API.
  Future<List<WallpaperModel>> fetchWallpapers({int page = 1}) async {
    final uri = Uri.parse(
      'https://wallpaperhub.app/api/v1/wallpapers?limit=20&page=$page',
    );

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          return _parseItems(decoded);
        } else if (decoded is Map<String, dynamic>) {
          final items = decoded['data'] ?? decoded['entities'] ?? [];
          if (items is List) {
            return _parseItems(items);
          }
        }
      }
    } catch (e) {
      debugPrint('WallpaperHubSource error: $e');
    }

    return const [];
  }

  List<WallpaperModel> _parseItems(List<dynamic> items) {
    final results = <WallpaperModel>[];

    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final entity = raw['entity'] as Map<String, dynamic>? ?? raw;

      final id = entity['id']?.toString() ?? '';
      final title = entity['title']?.toString() ?? 'WallpaperHub Wallpaper';
      final thumb = entity['thumbnail']?.toString() ?? '';
      final label = entity['label']?.toString() ?? 'Surface / Windows';

      // Find highest resolution
      String fullUrl = thumb;
      String resolution = '3840x2160 (4K UHD)';
      String ratio = '16:9';

      final variations = entity['variations'] as List<dynamic>? ?? [];
      if (variations.isNotEmpty && variations.first is Map<String, dynamic>) {
        final resList = variations.first['resolutions'] as List<dynamic>? ?? [];
        for (final r in resList) {
          if (r is! Map<String, dynamic>) continue;
          final resLabel = r['resolutionLabel']?.toString() ?? '';
          final url = r['url']?.toString() ?? '';
          if (url.isNotEmpty &&
              (resLabel.toLowerCase() == 'original' ||
                  resLabel.toLowerCase() == 'ultrawide' ||
                  fullUrl == thumb)) {
            fullUrl = url;
            final w = r['width']?.toString() ?? '3840';
            final h = r['height']?.toString() ?? '2160';
            resolution = '${w}x$h';
            break;
          }
        }
      }

      if (id.isNotEmpty && fullUrl.isNotEmpty) {
        results.add(
          WallpaperModel(
            id: 'hub_$id',
            title: title,
            author: label,
            sourceName: 'wallpaperhub.app',
            thumbUrl: thumb.isNotEmpty ? thumb : fullUrl,
            fullUrl: fullUrl,
            resolution: resolution,
            ratio: ratio,
            category: 'Modern & Minimal',
            colors: const [],
          ),
        );
      }
    }

    return results;
  }
}
