import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/windows_spotlight_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test(
    'WindowsSpotlightSource parses MSN delivery feed into WallpaperModels',
    () async {
      final innerJson = jsonEncode({
        'ad': {
          'title_text': {'tx': 'Ballena Marine National Park'},
          'image_fullscreen_002_landscape': {
            'u': 'https://res.public.onecdn.static.microsoft/spotlight.jpg',
            'w': '1920',
            'h': '1200',
          },
        },
      });

      final sampleJson = jsonEncode({
        'batchItems': [
          {'item': innerJson},
        ],
      });

      final mockClient = createMockHttpClient(
        responseBody: sampleJson,
        statusCode: 200,
      );

      final source = WindowsSpotlightSource(client: mockClient);
      final items = await source.fetchDailySpotlight();

      expect(items.length, equals(1));
      expect(items.first.title, contains('Ballena Marine'));
      expect(
        items.first.fullUrl,
        equals('https://res.public.onecdn.static.microsoft/spotlight.jpg'),
      );
      expect(items.first.sourceName, equals('Windows Spotlight'));
    },
  );

  test('WindowsSpotlightSource handles error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = WindowsSpotlightSource(client: mockClient);
    final items = await source.fetchDailySpotlight();
    expect(items, isEmpty);
  });
}
