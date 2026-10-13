import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/services/i_wallpaper_service.dart';

/// Fallback / mock implementation of wallpaper service for tests and non-Windows systems.
class NoopWallpaperService implements IWallpaperPlatformService {
  @override
  String get defaultSlideshowDirectory {
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.systemTemp.path;
    return p.join(home, 'Pictures', 'WallGem', 'Slideshow');
  }

  @override
  Future<bool> setWallpaper(String filePath) async {
    return true;
  }

  @override
  Future<File?> downloadWallpaper(
    String url, {
    required String fileName,
  }) async {
    final dir = Directory(defaultSlideshowDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File(p.join(dir.path, fileName));
    if (!file.existsSync()) {
      file.writeAsStringSync('dummy_image_data');
    }
    return file;
  }

  @override
  Future<void> openSlideshowDirectory() async {
    // No-op for tests
  }
}
