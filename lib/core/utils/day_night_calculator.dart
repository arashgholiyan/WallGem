/// Utility that calculates sun cycle phases (day vs. night)
/// and provides intelligent dynamic category recommendations.
class DayNightCalculator {
  /// Daytime begins at 06:00 and concludes at 19:59:59.
  static bool isDaytime(DateTime time) {
    return time.hour >= 6 && time.hour < 20;
  }

  /// Returns 'Landscape' during bright daytime hours and 'OLED Dark'
  /// during night hours to reduce eye strain and complement dark themes.
  static String getRecommendedCategory(DateTime time) {
    return isDaytime(time) ? 'Landscape' : 'OLED Dark';
  }
}
