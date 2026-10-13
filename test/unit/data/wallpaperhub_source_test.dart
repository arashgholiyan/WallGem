import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/wallpaperhub_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test(
    'WallpaperHubSource parses API response into 4K WallpaperModels',
    () async {
      const sampleJson = '''
      {
        "data": [
          {
            "entity": {
              "id": "16815",
              "title": "Autumn Park",
              "label": "Surface Wallpaper",
              "thumbnail": "https://cdn.wallpaperhub.app/thumb.jpg",
              "variations": [
                {
                  "resolutions": [
                    {
                      "width": 3840,
                      "height": 2160,
                      "resolutionLabel": "Original",
                      "url": "https://cdn.wallpaperhub.app/original_4k.jpg"
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
    ''';

      final mockClient = createMockHttpClient(
        responseBody: sampleJson,
        statusCode: 200,
      );

      final source = WallpaperHubSource(client: mockClient);
      final items = await source.fetchWallpapers(page: 1);

      expect(items.length, equals(1));
      expect(items.first.id, equals('hub_16815'));
      expect(items.first.title, equals('Autumn Park'));
      expect(
        items.first.fullUrl,
        equals('https://cdn.wallpaperhub.app/original_4k.jpg'),
      );
      expect(items.first.sourceName, equals('wallpaperhub.app'));
    },
  );

  test('WallpaperHubSource handles network error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = WallpaperHubSource(client: mockClient);
    final items = await source.fetchWallpapers(page: 1);
    expect(items, isEmpty);
  });
}
