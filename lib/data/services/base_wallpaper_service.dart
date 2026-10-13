import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../domain/services/i_wallpaper_service.dart';

/// Base class providing shared download and path resolution across desktop platforms.
abstract class BaseWallpaperService implements IWallpaperPlatformService {
  final http.Client client;

  BaseWallpaperService({http.Client? client})
    : client = client ?? http.Client();

  @override
  String get defaultSlideshowDirectory {
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return p.join(home, 'Pictures', 'WallGem', 'Slideshow');
  }

  @override
  Future<File?> downloadWallpaper(
    String url, {
    required String fileName,
  }) async {
    try {
      final dir = Directory(defaultSlideshowDirectory);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final file = File(p.join(dir.path, fileName));
      final res = await client
          .get(Uri.parse(url), headers: AppConstants.defaultHeaders)
          .timeout(AppConstants.downloadTimeout);

      if (res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('downloadWallpaper error: $e');
    }
    return null;
  }
}
