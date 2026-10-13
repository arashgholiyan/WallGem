import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'base_wallpaper_service.dart';

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
class WindowsWallpaperService extends BaseWallpaperService {
  WindowsWallpaperService({super.client});

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
