import 'package:flutter/material.dart';
import 'wallpaper.dart';

/// Represents a user's favorited wallpaper, persisting the save timestamp
/// and optional local file cache path.
class FavoriteWallpaper extends Wallpaper {
  final DateTime savedAt;
  final String? localFilePath;

  const FavoriteWallpaper({
    required super.id,
    required super.title,
    required super.author,
    required super.sourceName,
    required super.thumbUrl,
    required super.fullUrl,
    required super.resolution,
    required super.aspectRatio,
    required super.category,
    required super.dominantColors,
    required this.savedAt,
    this.localFilePath,
  });

  /// Creates a [FavoriteWallpaper] from an existing [Wallpaper].
  factory FavoriteWallpaper.fromWallpaper(
    Wallpaper wallpaper, {
    DateTime? savedAt,
    String? localFilePath,
  }) {
    return FavoriteWallpaper(
      id: wallpaper.id,
      title: wallpaper.title,
      author: wallpaper.author,
      sourceName: wallpaper.sourceName,
      thumbUrl: wallpaper.thumbUrl,
      fullUrl: wallpaper.fullUrl,
      resolution: wallpaper.resolution,
      aspectRatio: wallpaper.aspectRatio,
      category: wallpaper.category,
      dominantColors: wallpaper.dominantColors,
      savedAt: savedAt ?? DateTime.now(),
      localFilePath: localFilePath,
    );
  }

  /// Deserialization from JSON.
  factory FavoriteWallpaper.fromJson(Map<String, dynamic> json) {
    return FavoriteWallpaper(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Wallpaper',
      author: json['author'] as String? ?? 'Unknown Artist',
      sourceName: json['sourceName'] as String? ?? 'Unknown Source',
      thumbUrl: json['thumbUrl'] as String? ?? '',
      fullUrl: json['fullUrl'] as String? ?? '',
      resolution: json['resolution'] as String? ?? '3840x2160',
      aspectRatio: json['aspectRatio'] as String? ?? '16:9',
      category: json['category'] as String? ?? 'General',
      dominantColors:
          (json['dominantColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          const [],
      savedAt:
          json['savedAt'] != null
              ? DateTime.parse(json['savedAt'] as String)
              : DateTime.now(),
      localFilePath: json['localFilePath'] as String?,
    );
  }

  /// Serialization to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'sourceName': sourceName,
      'thumbUrl': thumbUrl,
      'fullUrl': fullUrl,
      'resolution': resolution,
      'aspectRatio': aspectRatio,
      'category': category,
      'dominantColors': dominantColors.map((c) => c.toARGB32()).toList(),
      'savedAt': savedAt.toIso8601String(),
      'localFilePath': localFilePath,
    };
  }

  @override
  FavoriteWallpaper copyWith({
    String? id,
    String? title,
    String? author,
    String? sourceName,
    String? thumbUrl,
    String? fullUrl,
    String? resolution,
    String? aspectRatio,
    String? category,
    List<Color>? dominantColors,
    DateTime? savedAt,
    String? localFilePath,
  }) {
    return FavoriteWallpaper(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      sourceName: sourceName ?? this.sourceName,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      fullUrl: fullUrl ?? this.fullUrl,
      resolution: resolution ?? this.resolution,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      category: category ?? this.category,
      dominantColors: dominantColors ?? this.dominantColors,
      savedAt: savedAt ?? this.savedAt,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }
}
