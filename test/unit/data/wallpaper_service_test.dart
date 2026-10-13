import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/services/i_wallpaper_service.dart';

void main() {
  test('NoopWallpaperService provides safe path and succeeds safely', () async {
    final IWallpaperPlatformService service = NoopWallpaperService();
    expect(service.defaultSlideshowDirectory, contains('WallGem'));
    final success = await service.setWallpaper('dummy/path.jpg');
    expect(success, isTrue);
  });
}
