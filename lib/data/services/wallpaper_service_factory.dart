import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/services/i_wallpaper_service.dart';
import 'linux_wallpaper_service.dart';
import 'macos_wallpaper_service.dart';
import 'noop_wallpaper_service.dart';
import 'windows_wallpaper_service.dart';

/// Factory creating the appropriate native platform wallpaper service.
class WallpaperServiceFactory {
  WallpaperServiceFactory._();

  /// Creates a platform-specific wallpaper service based on current OS.
  static IWallpaperPlatformService create({
    http.Client? client,
    bool? isWindows,
    bool? isMacOS,
    bool? isLinux,
  }) {
    final win = isWindows ?? Platform.isWindows;
    final mac = isMacOS ?? Platform.isMacOS;
    final lin = isLinux ?? Platform.isLinux;

    if (win) {
      return WindowsWallpaperService(client: client);
    } else if (mac) {
      return MacOSWallpaperService(client: client);
    } else if (lin) {
      return LinuxWallpaperService(client: client);
    }

    return NoopWallpaperService();
  }
}
