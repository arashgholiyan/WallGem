import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/models/wallpaper_model.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';

void main() {
  test('WallpaperModel serializes to and from JSON', () {
    const model = WallpaperModel(
      id: 'test_1',
      title: 'Neon Cyberpunk',
      author: 'CyberArtist',
      sourceName: 'wallhaven.cc',
      thumbUrl: 'https://example.com/thumb.jpg',
      fullUrl: 'https://example.com/full.jpg',
      resolution: '3840x2160',
      ratio: '16:9',
      category: 'Cyberpunk',
      colors: [Color(0xFF6366F1)],
    );

    final json = model.toJson();
    final reconstructed = WallpaperModel.fromJson(json);

    expect(reconstructed.id, equals(model.id));
    expect(reconstructed.title, equals(model.title));
    expect(reconstructed.toEntity(), isA<Wallpaper>());
  });

  test('WallpaperModel parses Wallhaven API item', () {
    final wallhavenItemJson = {
      'id': '9m9yvd',
      'path': 'https://w.wallhaven.cc/full/9m/wallhaven-9m9yvd.jpg',
      'thumbs': {
        'small': 'https://th.wallhaven.cc/small/9m/9m9yvd.jpg',
        'large': 'https://th.wallhaven.cc/lg/9m/9m9yvd.jpg',
      },
      'resolution': '3840x2160',
      'ratio': '1.78',
      'category': 'anime',
      'colors': ['#663399'],
      'uploader': {'username': 'Artist'},
    };

    final model = WallpaperModel.fromWallhavenJson(wallhavenItemJson);
    expect(model.id, equals('wallhaven_9m9yvd'));
    expect(model.sourceName, equals('wallhaven.cc'));
    expect(model.colors.isNotEmpty, isTrue);
    expect(
      model.colors.first.toARGB32(),
      equals(const Color(0xFF663399).toARGB32()),
    );
  });

  test('Wallpaper entity equality and copyWith work properly', () {
    const wallpaper1 = Wallpaper(
      id: '1',
      title: 'T1',
      author: 'A1',
      sourceName: 'S1',
      thumbUrl: 'u1',
      fullUrl: 'u2',
      resolution: '4K',
      aspectRatio: '16:9',
      category: 'Cat1',
      dominantColors: [],
    );

    final wallpaper2 = wallpaper1.copyWith(title: 'T2');
    expect(wallpaper2.id, equals('1'));
    expect(wallpaper2.title, equals('T2'));
    expect(wallpaper1 == wallpaper2, isFalse);
  });
}
