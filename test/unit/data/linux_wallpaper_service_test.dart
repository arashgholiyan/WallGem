import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/linux_wallpaper_service.dart';

void main() {
  test('LinuxWallpaperService sets wallpaper via GNOME gsettings', () async {
    final commandsRun = <String>[];
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      commandsRun.add(exec);
      return ProcessResult(123, 0, 'stdout', 'stderr');
    }

    final service = LinuxWallpaperService(processRunner: mockRunner);
    final success = await service.setWallpaper('/home/user/Pictures/test.jpg');

    expect(success, isTrue);
    expect(commandsRun, contains('gsettings'));
  });

  test(
    'LinuxWallpaperService falls back to feh when gsettings fails',
    () async {
      final commandsRun = <String>[];
      Future<ProcessResult> mockRunner(String exec, List<String> args) async {
        commandsRun.add(exec);
        if (exec == 'feh') {
          return ProcessResult(123, 0, '', '');
        }
        return ProcessResult(123, 1, '', 'not found');
      }

      final service = LinuxWallpaperService(processRunner: mockRunner);
      final success = await service.setWallpaper(
        '/home/user/Pictures/test.jpg',
      );

      expect(success, isTrue);
      expect(commandsRun, contains('feh'));
    },
  );

  test('LinuxWallpaperService sets wallpaper via swww on Wayland', () async {
    final commandsRun = <String>[];
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      commandsRun.add(exec);
      if (exec == 'swww') {
        return ProcessResult(123, 0, '', '');
      }
      return ProcessResult(123, 1, '', 'not found');
    }

    final service = LinuxWallpaperService(processRunner: mockRunner);
    final success = await service.setWallpaper('/home/user/Pictures/test.jpg');

    expect(success, isTrue);
    expect(commandsRun, contains('swww'));
  });

  test(
    'LinuxWallpaperService sets wallpaper via hyprctl on Hyprland',
    () async {
      final commandsRun = <String>[];
      Future<ProcessResult> mockRunner(String exec, List<String> args) async {
        commandsRun.add(exec);
        if (exec == 'hyprctl') {
          return ProcessResult(123, 0, '', '');
        }
        return ProcessResult(123, 1, '', 'not found');
      }

      final service = LinuxWallpaperService(processRunner: mockRunner);
      final success = await service.setWallpaper(
        '/home/user/Pictures/test.jpg',
      );

      expect(success, isTrue);
      expect(commandsRun, contains('hyprctl'));
    },
  );

  test('LinuxWallpaperService returns false when all setters fail', () async {
    Future<ProcessResult> mockRunner(String exec, List<String> args) async {
      return ProcessResult(123, 1, '', 'command not found');
    }

    final service = LinuxWallpaperService(processRunner: mockRunner);
    final success = await service.setWallpaper('/home/user/Pictures/test.jpg');

    expect(success, isFalse);
  });

  test(
    'LinuxWallpaperService openSlideshowDirectory invokes xdg-open',
    () async {
      String? calledExec;
      Future<ProcessResult> mockRunner(String exec, List<String> args) async {
        calledExec = exec;
        return ProcessResult(123, 0, '', '');
      }

      final service = LinuxWallpaperService(processRunner: mockRunner);
      await service.openSlideshowDirectory();

      expect(calledExec, equals('xdg-open'));
    },
  );
}
