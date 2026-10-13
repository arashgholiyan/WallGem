import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

/// Client for the Birdpaper / 360 open 4K wallpaper catalog.
class BirdpaperSource {
  final http.Client _client;

  BirdpaperSource({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches true 4K Ultra HD wallpapers by category.
  Future<List<WallpaperModel>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    final cid = _mapCategoryToCid(category);
    final start = (page - 1) * 20;
    final uri = Uri.parse(
      'http://wallpaper.apc.360.cn/index.php?c=WallPaper&a=getAppsByCategory&cid=$cid&start=$start&count=20&from=360chrome',
    );

    try {
      final res = await _client
          .get(uri, headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.networkTimeout);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final data = decoded['data'] as List<dynamic>? ?? [];
        return parseItems(data);
      }
    } catch (e) {
      debugPrint('BirdpaperSource error: $e');
    }

    return const [];
  }

  /// Parses items into WallpaperModels.
  List<WallpaperModel> parseItems(List<dynamic> data) {
    final results = <WallpaperModel>[];

    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;

      final id = raw['id']?.toString() ?? '';
      final fullUrl = raw['url']?.toString() ?? '';
      final thumbUrl =
          raw['url_mid']?.toString() ??
          raw['img_1600_900']?.toString() ??
          fullUrl;
      final resolution = raw['resolution']?.toString() ?? '3840x2160 (4K)';
      final tag = raw['utag']?.toString() ?? 'Birdpaper 4K';

      if (id.isNotEmpty && fullUrl.isNotEmpty) {
        results.add(
          WallpaperModel(
            id: 'bird_$id',
            title: tag.isNotEmpty ? tag : 'Birdpaper #$id',
            author: 'Birdpaper 4K Studio',
            sourceName: 'birdpaper.com.cn',
            thumbUrl: thumbUrl,
            fullUrl: fullUrl,
            resolution: resolution,
            ratio: '16:9',
            category: '4K Ultra HD',
            colors: const [],
          ),
        );
      }
    }

    return results;
  }

  String _mapCategoryToCid(String category) {
    final cat = category.toLowerCase();
    if (cat == 'landscape' || cat == 'nature') return '9';
    if (cat == 'anime') return '26';
    if (cat == 'gaming' || cat == 'games') return '5';
    if (cat == 'cars' || cat == 'vehicles') return '12';
    if (cat == 'pets' || cat == 'animals') return '14';
    // Default to 4K Ultra HD category
    return '36';
  }
}
