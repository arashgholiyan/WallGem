import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/linux_wallpaper_service.dart';
import 'package:wall_gem/data/services/macos_wallpaper_service.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/data/services/wallpaper_service_factory.dart';
import 'package:wall_gem/data/services/windows_wallpaper_service.dart';

void main() {
  test('WallpaperServiceFactory instantiates WindowsWallpaperService', () {
    final service = WallpaperServiceFactory.create(
      isWindows: true,
      isMacOS: false,
      isLinux: false,
    );
    expect(service, isA<WindowsWallpaperService>());
  });

  test('WallpaperServiceFactory instantiates MacOSWallpaperService', () {
    final service = WallpaperServiceFactory.create(
      isWindows: false,
      isMacOS: true,
      isLinux: false,
    );
    expect(service, isA<MacOSWallpaperService>());
  });

  test('WallpaperServiceFactory instantiates LinuxWallpaperService', () {
    final service = WallpaperServiceFactory.create(
      isWindows: false,
      isMacOS: false,
      isLinux: true,
    );
    expect(service, isA<LinuxWallpaperService>());
  });

  test('WallpaperServiceFactory falls back to NoopWallpaperService', () {
    final service = WallpaperServiceFactory.create(
      isWindows: false,
      isMacOS: false,
      isLinux: false,
    );
    expect(service, isA<NoopWallpaperService>());
  });
}
