import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/data/services/favorites_storage_service.dart';
import 'package:wall_gem/data/repositories/favorites_repository_impl.dart';

void main() {
  late Directory tempDir;
  late String testFilePath;
  late FavoritesStorageService storageService;
  late FavoritesRepositoryImpl repository;

  final sampleWallpaper = Wallpaper(
    id: 'wall-001',
    title: 'Neon Cyberpunk City',
    author: 'Kavinsky',
    sourceName: 'Curated',
    thumbUrl: 'https://images.unsplash.com/thumb-001',
    fullUrl: 'https://images.unsplash.com/full-001',
    resolution: '3840x2160',
    aspectRatio: '16:9',
    category: 'Cyberpunk',
    dominantColors: const [Color(0xFF6366F1), Color(0xFFEC4899)],
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wall_gem_favorites_test_');
    testFilePath = '${tempDir.path}${Platform.pathSeparator}favorites.json';
    storageService = FavoritesStorageService(storagePath: testFilePath);
    repository = FavoritesRepositoryImpl(storageService: storageService);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('loadFavorites returns empty list when file does not exist', () async {
    final list = await storageService.loadFavorites();
    expect(list, isEmpty);
  });

  test(
    'saveFavorite saves and loadFavorites restores FavoriteWallpaper',
    () async {
      await repository.saveFavorite(
        sampleWallpaper,
        localPath: 'C:/Pictures/sample.jpg',
      );

      final favorites = await repository.loadFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 'wall-001');
      expect(favorites.first.title, 'Neon Cyberpunk City');
      expect(favorites.first.localFilePath, 'C:/Pictures/sample.jpg');
      expect(favorites.first.dominantColors.length, 2);

      final isFav = await repository.isFavorite('wall-001');
      expect(isFav, isTrue);
    },
  );

  test('saveFavorite deduplicates items with same id', () async {
    await repository.saveFavorite(sampleWallpaper);
    await repository.saveFavorite(sampleWallpaper);

    final favorites = await repository.loadFavorites();
    expect(favorites.length, 1);
  });

  test('removeFavorite deletes wallpaper by id', () async {
    await repository.saveFavorite(sampleWallpaper);
    expect(await repository.isFavorite('wall-001'), isTrue);

    await repository.removeFavorite('wall-001');
    expect(await repository.isFavorite('wall-001'), isFalse);
    expect(await repository.loadFavorites(), isEmpty);
  });

  test(
    'recovers gracefully from corrupted JSON file without crashing',
    () async {
      final file = File(testFilePath);
      await file.parent.create(recursive: true);
      await file.writeAsString('{ corrupted json syntax [[[');

      final favorites = await storageService.loadFavorites();
      expect(favorites, isEmpty);
    },
  );
}
