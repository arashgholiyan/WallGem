import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/core/utils/day_night_calculator.dart';

void main() {
  group('DayNightCalculator', () {
    test('06:00 to 19:59 is considered daytime and recommends Landscape', () {
      final morning = DateTime(2026, 10, 13, 6, 0);
      final noon = DateTime(2026, 10, 13, 12, 0);
      final evening = DateTime(2026, 10, 13, 19, 59);

      expect(DayNightCalculator.isDaytime(morning), isTrue);
      expect(DayNightCalculator.getRecommendedCategory(morning), 'Landscape');

      expect(DayNightCalculator.isDaytime(noon), isTrue);
      expect(DayNightCalculator.getRecommendedCategory(noon), 'Landscape');

      expect(DayNightCalculator.isDaytime(evening), isTrue);
      expect(DayNightCalculator.getRecommendedCategory(evening), 'Landscape');
    });

    test('20:00 to 05:59 is considered nighttime and recommends OLED Dark', () {
      final nightStart = DateTime(2026, 10, 13, 20, 0);
      final midnight = DateTime(2026, 10, 13, 0, 0);
      final lateNight = DateTime(2026, 10, 13, 3, 30);
      final dawnEdge = DateTime(2026, 10, 13, 5, 59);

      expect(DayNightCalculator.isDaytime(nightStart), isFalse);
      expect(
        DayNightCalculator.getRecommendedCategory(nightStart),
        'OLED Dark',
      );

      expect(DayNightCalculator.isDaytime(midnight), isFalse);
      expect(DayNightCalculator.getRecommendedCategory(midnight), 'OLED Dark');

      expect(DayNightCalculator.isDaytime(lateNight), isFalse);
      expect(DayNightCalculator.getRecommendedCategory(lateNight), 'OLED Dark');

      expect(DayNightCalculator.isDaytime(dawnEdge), isFalse);
      expect(DayNightCalculator.getRecommendedCategory(dawnEdge), 'OLED Dark');
    });
  });
}
