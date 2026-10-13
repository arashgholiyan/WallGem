import 'package:flutter/material.dart';

/// Core domain entity representing a high-resolution wallpaper.
class Wallpaper {
  final String id;
  final String title;
  final String author;
  final String sourceName;
  final String thumbUrl;
  final String fullUrl;
  final String resolution;
  final String aspectRatio;
  final String category;
  final List<Color> dominantColors;

  const Wallpaper({
    required this.id,
    required this.title,
    required this.author,
    required this.sourceName,
    required this.thumbUrl,
    required this.fullUrl,
    required this.resolution,
    required this.aspectRatio,
    required this.category,
    required this.dominantColors,
  });

  Wallpaper copyWith({
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
  }) {
    return Wallpaper(
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          author == other.author &&
          sourceName == other.sourceName &&
          thumbUrl == other.thumbUrl &&
          fullUrl == other.fullUrl &&
          resolution == other.resolution &&
          aspectRatio == other.aspectRatio &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      author.hashCode ^
      sourceName.hashCode ^
      thumbUrl.hashCode ^
      fullUrl.hashCode ^
      resolution.hashCode ^
      aspectRatio.hashCode ^
      category.hashCode;
}
