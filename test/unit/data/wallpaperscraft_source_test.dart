import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/wallpaperscraft_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('WallpapersCraftSource parses HTML into WallpaperModels', () async {
    const sampleHtml = '''
      <html><body>
        <img class="wallpapers__image" src="https://images.wallpaperscraft.com/image/single/forest_trees_river_1725448_300x168.jpg" alt="Preview wallpaper forest, trees, river">
      </body></html>
    ''';

    final mockClient = createMockHttpClient(
      responseBody: sampleHtml,
      statusCode: 200,
    );

    final source = WallpapersCraftSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'Landscape', page: 1);

    expect(items.length, equals(1));
    expect(items.first.id, equals('craft_forest_trees_river_1725448'));
    expect(
      items.first.fullUrl,
      equals(
        'https://images.wallpaperscraft.com/image/single/forest_trees_river_1725448_1920x1080.jpg',
      ),
    );
    expect(items.first.title, contains('forest, trees, river'));
    expect(items.first.sourceName, equals('wallpaperscraft.com'));
  });

  test('WallpapersCraftSource handles 500 error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = WallpapersCraftSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);
    expect(items, isEmpty);
  });
}
