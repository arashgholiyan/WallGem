import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/birdpaper_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('BirdpaperSource parses 4K items into WallpaperModels', () async {
    const sampleJson = '''
      {
        "errno": "0",
        "data": [
          {
            "id": "2054208",
            "resolution": "3840x2160",
            "url": "http://p5.qhimg.com/full_4k.jpg",
            "url_mid": "http://p5.qhimg.com/thumb.jpg",
            "utag": "4K Futuristic Neon"
          }
        ]
      }
    ''';

    final mockClient = createMockHttpClient(
      responseBody: sampleJson,
      statusCode: 200,
    );

    final source = BirdpaperSource(client: mockClient);
    final items = await source.fetchWallpapers(category: '4K', page: 1);

    expect(items.length, equals(1));
    expect(items.first.id, equals('bird_2054208'));
    expect(items.first.fullUrl, equals('http://p5.qhimg.com/full_4k.jpg'));
    expect(items.first.title, contains('4K Futuristic Neon'));
    expect(items.first.sourceName, equals('birdpaper.com.cn'));
  });

  test('BirdpaperSource handles error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = BirdpaperSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);
    expect(items, isEmpty);
  });
}
