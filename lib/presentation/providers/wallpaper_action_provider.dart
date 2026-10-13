import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/services/i_wallpaper_service.dart';

/// Presentation state controller managing wallpaper download, application, and folder opening.
class WallpaperActionProvider extends ChangeNotifier {
  final IWallpaperPlatformService _service;

  bool _isApplying = false;
  String? _statusMessage;

  WallpaperActionProvider({required IWallpaperPlatformService service})
    : _service = service;

  bool get isApplying => _isApplying;
  String? get statusMessage => _statusMessage;
  String get slideshowDirectory => _service.defaultSlideshowDirectory;

  /// Applies [wallpaper] as the Windows desktop background.
  Future<bool> applyAsWallpaper(Wallpaper wallpaper) async {
    _isApplying = true;
    _statusMessage = 'Downloading high-resolution wallpaper...';
    notifyListeners();

    try {
      final ext = wallpaper.fullUrl.contains('.png') ? '.png' : '.jpg';
      final fileName = 'liked_${wallpaper.id}$ext';

      final file = await _service.downloadWallpaper(
        wallpaper.fullUrl,
        fileName: fileName,
      );

      if (file != null && file.existsSync()) {
        _statusMessage = 'Applying as desktop wallpaper...';
        notifyListeners();

        final success = await _service.setWallpaper(file.path);
        _isApplying = false;
        _statusMessage = success
            ? 'Wallpaper applied!'
            : 'Failed to set wallpaper';
        notifyListeners();
        return success;
      }
    } catch (e) {
      debugPrint('applyAsWallpaper error: $e');
    }

    _isApplying = false;
    _statusMessage = 'Failed to download wallpaper';
    notifyListeners();
    return false;
  }

  /// Downloads all wallpapers in [wallpapers] to the local slideshow directory.
  Future<void> saveBatchToDisk(List<Wallpaper> wallpapers) async {
    for (final w in wallpapers) {
      final ext = w.fullUrl.contains('.png') ? '.png' : '.jpg';
      final fileName = 'liked_${w.id}$ext';
      final targetPath = '${_service.defaultSlideshowDirectory}/$fileName';

      if (!File(targetPath).existsSync()) {
        await _service.downloadWallpaper(w.fullUrl, fileName: fileName);
      }
    }
  }

  /// Opens the wallpaper directory in Windows File Explorer.
  Future<void> openFolder() async {
    await _service.openSlideshowDirectory();
  }
}
