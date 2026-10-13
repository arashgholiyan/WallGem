/// Global application constants for Wall Gem.
class AppConstants {
  AppConstants._();

  static const String appName = 'Wall Gem';
  static const String appTagline = '4K Discovery & Desktop Engine';
  static const String appVersion = '1.1.0';

  /// Number of liked wallpapers to trigger batch slideshow completion
  static const int batchTarget = 5;

  /// Distinct wallpaper provider platforms
  static const List<String> sources = [
    'All Sources',
    'WallpapersWide',
    'WallpapersCraft',
    'AlphaCoders',
    '4K Wallpapers',
    'WallpaperHub',
    'Birdpaper 4K',
    'Wallhaven',
    'Bing Daily',
    'Windows Spotlight',
    'Picsum Photos',
  ];

  /// Default categories available in the category selector
  static const List<String> categories = [
    'All',
    'Landscape',
    'Gaming',
    'Anime',
    'Cars',
    'Cyberpunk',
    'Space',
    'OLED Dark',
    'Ultrawide',
    'Minimal',
    'Architecture',
  ];

  /// HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/html, */*',
  };

  /// Timeouts
  static const Duration networkTimeout = Duration(seconds: 8);
  static const Duration downloadTimeout = Duration(seconds: 25);
}
