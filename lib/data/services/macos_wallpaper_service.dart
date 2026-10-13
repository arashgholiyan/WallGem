import 'dart:io';
import 'package:flutter/foundation.dart';
import 'base_wallpaper_service.dart';

/// Concrete macOS implementation interacting with System Events via osascript.
class MacOSWallpaperService extends BaseWallpaperService {
  final Future<ProcessResult> Function(String, List<String>)? processRunner;

  MacOSWallpaperService({super.client, this.processRunner});

  @override
  Future<bool> setWallpaper(String filePath) async {
    final runner = processRunner ?? Process.run;
    // Escapes double quotes in file paths
    final sanitizedPath = filePath.replaceAll('"', r'\"');
    final script =
        'tell application "System Events" to tell every desktop to set picture to "$sanitizedPath"';

    try {
      final res = await runner('osascript', ['-e', script]);
      return res.exitCode == 0;
    } catch (e) {
      debugPrint('MacOSWallpaperService error: $e');
      return false;
    }
  }

  @override
  Future<void> openSlideshowDirectory() async {
    final dir = Directory(defaultSlideshowDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final runner = processRunner ?? Process.run;
    try {
      await runner('open', [dir.path]);
    } catch (e) {
      debugPrint('MacOS openSlideshowDirectory error: $e');
    }
  }
}
