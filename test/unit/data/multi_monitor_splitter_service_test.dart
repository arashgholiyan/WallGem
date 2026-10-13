import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/multi_monitor_splitter_service.dart';

void main() {
  group('MultiMonitorSplitterService', () {
    test('isPanoramic accurately classifies panoramic and ultrawide resolutions and ratios', () {
      expect(MultiMonitorSplitterService.isPanoramic('5120x1440', '32:9'), isTrue);
      expect(MultiMonitorSplitterService.isPanoramic('3440x1440', '21:9'), isTrue);
      expect(MultiMonitorSplitterService.isPanoramic('3840x1080', '32:9'), isTrue);
      expect(MultiMonitorSplitterService.isPanoramic('5120x1440', ''), isTrue);

      // Non-panoramic standard displays
      expect(MultiMonitorSplitterService.isPanoramic('3840x2160', '16:9'), isFalse);
      expect(MultiMonitorSplitterService.isPanoramic('2560x1440', '16:9'), isFalse);
      expect(MultiMonitorSplitterService.isPanoramic('1920x1200', '16:10'), isFalse);
    });

    test('calculateSplitBounds bisects dimensions into left and right screen rects', () {
      final bounds = MultiMonitorSplitterService.calculateSplitBounds(5120, 1440);

      expect(bounds.left, equals(const Rect.fromLTWH(0, 0, 2560, 1440)));
      expect(bounds.right, equals(const Rect.fromLTWH(2560, 0, 2560, 1440)));
    });

    test('generateSplitFileNames formats clean filenames for left and right displays', () {
      final names = MultiMonitorSplitterService.generateSplitFileNames('cyberpunk_city.jpg');

      expect(names.left, equals('cyberpunk_city_display1_left.jpg'));
      expect(names.right, equals('cyberpunk_city_display2_right.jpg'));
    });
  });
}
