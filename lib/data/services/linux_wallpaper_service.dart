import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'base_wallpaper_service.dart';

/// Concrete Linux implementation supporting GNOME, KDE, XFCE, Cinnamon, and generic window managers (feh/nitrogen).
class LinuxWallpaperService extends BaseWallpaperService {
  final Future<ProcessResult> Function(String, List<String>)? processRunner;

  LinuxWallpaperService({super.client, this.processRunner});

  @override
  Future<bool> setWallpaper(String filePath) async {
    final runner = processRunner ?? Process.run;
    final fileUri = 'file://${p.canonicalize(filePath)}';

    // 1. GNOME / Cinnamon / MATE via gsettings
    try {
      final rLight = await runner('gsettings', [
        'set',
        'org.gnome.desktop.background',
        'picture-uri',
        fileUri,
      ]);
      await runner('gsettings', [
        'set',
        'org.gnome.desktop.background',
        'picture-uri-dark',
        fileUri,
      ]);
      if (rLight.exitCode == 0) return true;
    } catch (_) {}

    // 2. KDE Plasma via qdbus script injection
    try {
      const kdeScript = '''
var allDesktops = desktops();
for (var i=0; i<allDesktops.length; i++) {
    var d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "%URI%");
}
''';
      final formattedScript = kdeScript.replaceAll('%URI%', fileUri);
      final rKde = await runner('qdbus', [
        'org.kde.plasmashell',
        '/PlasmaShell',
        'org.kde.PlasmaShell.evaluateScript',
        formattedScript,
      ]);
      if (rKde.exitCode == 0) return true;
    } catch (_) {}

    // 3. XFCE desktop via xfconf-query
    try {
      final rXfce = await runner('xfconf-query', [
        '-c',
        'xfce4-desktop',
        '-p',
        '/backdrop/screen0/monitor0/workspace0/last-image',
        '-s',
        filePath,
      ]);
      if (rXfce.exitCode == 0) return true;
    } catch (_) {}

    // 4. feh (common on i3, bspwm, awesomewm, dwm)
    try {
      final rFeh = await runner('feh', ['--bg-fill', filePath]);
      if (rFeh.exitCode == 0) return true;
    } catch (_) {}

    // 5. nitrogen fallback
    try {
      final rNitrogen = await runner('nitrogen', ['--set-zoom-fill', filePath]);
      if (rNitrogen.exitCode == 0) return true;
    } catch (_) {}

    debugPrint('LinuxWallpaperService: No supported desktop setter found.');
    return false;
  }

  @override
  Future<void> openSlideshowDirectory() async {
    final dir = Directory(defaultSlideshowDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final runner = processRunner ?? Process.run;
    try {
      await runner('xdg-open', [dir.path]);
    } catch (e) {
      debugPrint('Linux openSlideshowDirectory error: $e');
    }
  }
}
