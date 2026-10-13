import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/favorite_wallpaper.dart';

/// Service managing atomic read and write operations on the human-readable
/// `favorites.json` store located in the user's Pictures/WallGem directory.
class FavoritesStorageService {
  final String? storagePath;

  FavoritesStorageService({this.storagePath});

  /// Resolves the absolute path to `favorites.json`.
  File getStorageFile() {
    if (storagePath != null) {
      return File(storagePath!);
    }

    String basePath;
    if (Platform.isWindows) {
      basePath =
          Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          Directory.current.path;
    } else {
      basePath = Platform.environment['HOME'] ?? Directory.current.path;
    }

    final separator = Platform.pathSeparator;
    return File('$basePath${separator}Pictures${separator}WallGem${separator}favorites.json');
  }

  /// Loads all favorited wallpapers from the JSON file.
  /// If the file is missing or corrupted, gracefully returns an empty list.
  Future<List<FavoriteWallpaper>> loadFavorites() async {
    try {
      final file = getStorageFile();
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(content);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => FavoriteWallpaper.fromJson(item))
          .toList();
    } catch (e, stack) {
      debugPrint('FavoritesStorageService: Recovery from unreadable JSON: $e\n$stack');
      return [];
    }
  }

  /// Saves the full list of favorites to disk.
  Future<void> saveFavorites(List<FavoriteWallpaper> favorites) async {
    try {
      final file = getStorageFile();
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(
        favorites.map((f) => f.toJson()).toList(),
      );

      // Write with flush to guarantee persistence
      await file.writeAsString(jsonString, flush: true);
    } catch (e, stack) {
      debugPrint('FavoritesStorageService: Failed to save favorites: $e\n$stack');
      rethrow;
    }
  }
}
