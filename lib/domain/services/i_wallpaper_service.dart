import 'dart:io';

/// Platform-agnostic contract for setting and managing desktop wallpapers.
abstract class IWallpaperPlatformService {
  /// Sets the image at [filePath] as the active desktop wallpaper.
  Future<bool> setWallpaper(String filePath);

  /// Downloads the high-resolution wallpaper from [url] and saves to [destinationDirectory].
  Future<File?> downloadWallpaper(String url, {required String fileName});

  /// The path to the folder where saved/liked wallpapers are stored.
  String get defaultSlideshowDirectory;

  /// Opens the wallpaper slideshow directory in the native file explorer.
  Future<void> openSlideshowDirectory();
}
