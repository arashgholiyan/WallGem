import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Service responsible for identifying panoramic / ultrawide wallpapers (21:9, 32:9)
/// and calculating geometric split bounds for dual-monitor and multi-monitor setups.
class MultiMonitorSplitterService {
  /// Checks whether a resolution and aspect ratio qualify as panoramic (aspect >= 2.0).
  static bool isPanoramic(String resolution, String ratio) {
    if (ratio.contains('21:9') || ratio.contains('32:9') || ratio.contains('48:9')) {
      return true;
    }

    final match = RegExp(r'(\d+)\s*x\s*(\d+)').firstMatch(resolution);
    if (match != null) {
      final width = int.tryParse(match.group(1) ?? '') ?? 0;
      final height = int.tryParse(match.group(2) ?? '') ?? 0;
      if (width > 0 && height > 0) {
        return (width / height) >= 2.0;
      }
    }

    return false;
  }

  /// Calculates geometric bisected sub-rectangles for left (Display 1) and right (Display 2) screens.
  static ({Rect left, Rect right}) calculateSplitBounds(int width, int height) {
    final halfWidth = width / 2.0;
    final h = height.toDouble();

    return (
      left: Rect.fromLTWH(0, 0, halfWidth, h),
      right: Rect.fromLTWH(halfWidth, 0, halfWidth, h),
    );
  }

  /// Generates clean file names for left and right display slices.
  static ({String left, String right}) generateSplitFileNames(String originalFileName) {
    final ext = p.extension(originalFileName);
    final base = p.basenameWithoutExtension(originalFileName);

    return (
      left: '${base}_display1_left$ext',
      right: '${base}_display2_right$ext',
    );
  }

  /// Resolves the dedicated MultiMonitor directory in Pictures/WallGem/MultiMonitor.
  static Directory getMultiMonitorDirectory() {
    String basePath;
    if (Platform.isWindows) {
      basePath =
          Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          Directory.current.path;
    } else {
      basePath = Platform.environment['HOME'] ?? Directory.current.path;
    }

    final separator = Platform.pathSeparator;
    return Directory('$basePath${separator}Pictures${separator}WallGem${separator}MultiMonitor');
  }
}
