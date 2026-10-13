import 'package:flutter/material.dart';
import '../../domain/entities/wallpaper.dart';

/// Data Transfer Object for Wallpaper entities.
class WallpaperModel {
  final String id;
  final String title;
  final String author;
  final String sourceName;
  final String thumbUrl;
  final String fullUrl;
  final String resolution;
  final String ratio;
  final String category;
  final List<Color> colors;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.author,
    required this.sourceName,
    required this.thumbUrl,
    required this.fullUrl,
    required this.resolution,
    required this.ratio,
    required this.category,
    required this.colors,
  });

  /// Converts this model to a domain entity.
  Wallpaper toEntity() {
    return Wallpaper(
      id: id,
      title: title,
      author: author,
      sourceName: sourceName,
      thumbUrl: thumbUrl,
      fullUrl: fullUrl,
      resolution: resolution,
      aspectRatio: ratio,
      category: category,
      dominantColors: colors,
    );
  }

  /// Deserialization from internal JSON format.
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Wallpaper',
      author: json['author'] as String? ?? 'Unknown Artist',
      sourceName: json['sourceName'] as String? ?? 'Unknown Source',
      thumbUrl: json['thumbUrl'] as String? ?? '',
      fullUrl: json['fullUrl'] as String? ?? '',
      resolution: json['resolution'] as String? ?? '3840x2160 (4K)',
      ratio: json['ratio'] as String? ?? '16:9',
      category: json['category'] as String? ?? 'General',
      colors:
          (json['colors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          const [],
    );
  }

  /// Serialization to internal JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'sourceName': sourceName,
      'thumbUrl': thumbUrl,
      'fullUrl': fullUrl,
      'resolution': resolution,
      'ratio': ratio,
      'category': category,
      'colors': colors.map((c) => c.toARGB32()).toList(),
    };
  }

  /// Factory parser for Wallhaven v1 API search responses.
  factory WallpaperModel.fromWallhavenJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? 'unknown';
    final fullPath = json['path']?.toString() ?? '';
    final thumbs = json['thumbs'] as Map<String, dynamic>?;
    final thumbPath =
        thumbs?['large']?.toString() ??
        thumbs?['small']?.toString() ??
        fullPath;
    final res = json['resolution']?.toString() ?? '3840x2160 (4K)';
    final ratio = json['ratio']?.toString() ?? '16:9';
    final rawCategory = json['category']?.toString() ?? 'General';
    final uploader = json['uploader'] as Map<String, dynamic>?;
    final artist = uploader?['username']?.toString() ?? 'Wallhaven Community';

    // Parse hex colors (e.g. "#663399" or "663399")
    final rawColors = json['colors'] as List<dynamic>? ?? [];
    final parsedColors = <Color>[];
    for (final c in rawColors) {
      final hex = c.toString().replaceAll('#', '');
      if (hex.length == 6) {
        final val = int.tryParse('FF$hex', radix: 16);
        if (val != null) parsedColors.add(Color(val));
      }
    }

    String category = 'General';
    final lowerCat = rawCategory.toLowerCase();
    if (lowerCat.contains('anime')) {
      category = 'Anime';
    } else if (lowerCat.contains('people')) {
      category = 'Portrait';
    } else {
      category = 'Landscape';
    }

    return WallpaperModel(
      id: 'wallhaven_$rawId',
      title: 'Wallhaven #$rawId',
      author: artist,
      sourceName: 'wallhaven.cc',
      thumbUrl: thumbPath,
      fullUrl: fullPath,
      resolution: '$res (UHD)',
      ratio: ratio,
      category: category,
      colors: parsedColors.isNotEmpty
          ? parsedColors
          : const [Color(0xFF6366F1), Color(0xFF1E1B4B)],
    );
  }

  /// Factory parser for Bing Daily Wallpaper HPImageArchive format.
  factory WallpaperModel.fromBingJson(Map<String, dynamic> json) {
    final hsh = json['hsh']?.toString() ?? 'bing';
    final urlBase = json['urlbase']?.toString() ?? '';
    final rawUrl = json['url']?.toString() ?? '';
    final copyright = json['copyright']?.toString() ?? 'Bing Daily Wallpaper';
    final title =
        json['title']?.toString() ?? copyright.split('(').first.trim();

    // UHD resolution url
    final fullUrl = urlBase.isNotEmpty
        ? 'https://www.bing.com${urlBase}_UHD.jpg'
        : 'https://www.bing.com$rawUrl';
    final thumbUrl = urlBase.isNotEmpty
        ? 'https://www.bing.com${urlBase}_1920x1080.jpg'
        : 'https://www.bing.com$rawUrl';

    return WallpaperModel(
      id: 'bing_$hsh',
      title: title.isEmpty ? 'Bing Daily Wallpaper' : title,
      author: copyright,
      sourceName: 'bing.com',
      thumbUrl: thumbUrl,
      fullUrl: fullUrl,
      resolution: '3840x2160 (4K UHD)',
      ratio: '16:9',
      category: 'Landscape',
      colors: const [Color(0xFF0284C7), Color(0xFF0F172A)],
    );
  }
}
