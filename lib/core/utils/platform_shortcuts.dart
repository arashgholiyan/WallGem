import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralized utility for platform-specific keyboard shortcuts, conventions, and terminology.
class PlatformShortcuts {
  PlatformShortcuts._();

  /// Whether running on macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Whether running on Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Whether running on Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Primary modifier symbol (⌘ on macOS, Ctrl on Windows & Linux).
  static String get modifierKey => isMacOS ? '⌘' : 'Ctrl';

  /// Shortcut badge text for search command bar (⌘K on macOS, Ctrl+K on Windows/Linux).
  static String get searchBadge => isMacOS ? '⌘K' : 'Ctrl+K';

  /// Tooltip description for the search command bar.
  static String get searchTooltip => 'Search favorites ($searchBadge or /)';

  /// Terminology for slideshow wallpaper collection adapted to host OS.
  static String get slideshowPlatformLabel {
    if (isWindows) return 'Windows Slideshow';
    if (isMacOS) return 'macOS Screensaver & Wallpaper';
    return 'Desktop Wallpaper Collection';
  }
}
