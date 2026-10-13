import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/macos_wallpaper_service.dart';

void main() {
  test('MacOSWallpaperService sets wallpaper via osascript', () async {
    String? calledExec;
    List<String>? calledArgs;
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      calledExec = exec;
      calledArgs = args;
      return ProcessResult(123, 0, '', '');
    }

    final service = MacOSWallpaperService(processRunner: mockRunner);
    final success = await service.setWallpaper(
      '/Users/test/Pictures/wallpaper.jpg',
    );

    expect(success, isTrue);
    expect(calledExec, equals('osascript'));
    expect(calledArgs, isNotEmpty);
    expect(calledArgs!.last, contains('System Events'));
  });

  test('MacOSWallpaperService returns false on osascript failure', () async {
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      return ProcessResult(123, 1, '', 'AppleScript error');
    }

    final service = MacOSWallpaperService(processRunner: mockRunner);
    final success = await service.setWallpaper(
      '/Users/test/Pictures/wallpaper.jpg',
    );

    expect(success, isFalse);
  });

  test('MacOSWallpaperService openSlideshowDirectory invokes open', () async {
    String? calledExec;
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      calledExec = exec;
      return ProcessResult(123, 0, '', '');
    }

    final service = MacOSWallpaperService(processRunner: mockRunner);
    await service.openSlideshowDirectory();

    expect(calledExec, equals('open'));
  });
}
