import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../domain/services/i_wallpaper_service.dart';

typedef _SystemParametersInfoWNative =
    Int32 Function(
      Uint32 uiAction,
      Uint32 uiParam,
      Pointer<Utf16> pvParam,
      Uint32 fWinIni,
    );
typedef _SystemParametersInfoWDart =
    int Function(
      int uiAction,
      int uiParam,
      Pointer<Utf16> pvParam,
      int fWinIni,
    );

/// Concrete Windows implementation interacting with user32.dll via Dart FFI.
class WindowsWallpaperService implements IWallpaperPlatformService {
  final http.Client _client;

  WindowsWallpaperService({http.Client? client})
    : _client = client ?? http.Client();

  @override
  String get defaultSlideshowDirectory {
    final userProfile =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return p.join(userProfile, 'Pictures', 'WallGem', 'Slideshow');
  }

  @override
  Future<bool> setWallpaper(String filePath) async {
    if (!Platform.isWindows) {
      debugPrint(
        'Non-Windows platform detected; wallpaper application skipped.',
      );
      return false;
    }

    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final _SystemParametersInfoWDart systemParametersInfoW = user32
          .lookupFunction<
            _SystemParametersInfoWNative,
            _SystemParametersInfoWDart
          >('SystemParametersInfoW');

      final pathPointer = filePath.toNativeUtf16();
      const spiSetDeskWallpaper = 20;
      const spifUpdateIniFile = 0x01;
      const spifSendChange = 0x02;

      try {
        final result = systemParametersInfoW(
          spiSetDeskWallpaper,
          0,
          pathPointer,
          spifUpdateIniFile | spifSendChange,
        );
        return result != 0;
      } finally {
        calloc.free(pathPointer);
      }
    } catch (e) {
      debugPrint('WindowsWallpaperService FFI error: $e');
      return false;
    }
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
      final res = await _client
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

  @override
  Future<void> openSlideshowDirectory() async {
    final dir = Directory(defaultSlideshowDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [dir.path]);
    }
  }
}
