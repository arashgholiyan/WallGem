import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/wallpaperswide_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('WallpapersWideSource parses HTML into 4K WallpaperModels', () async {
    const sampleHtml = '''
      <html><body>
        <div class="thumb">
          <img src="https://hd.wallpaperswide.com/thumbs/epic_sunset_illustration-t1.jpg" alt="Epic Sunset Illustration 4K UHD Wallpaper" class="thumb_img" itemprop="thumbnail" />
        </div>
      </body></html>
    ''';

    final mockClient = createMockHttpClient(
      responseBody: sampleHtml,
      statusCode: 200,
    );

    final source = WallpapersWideSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'Landscape', page: 1);

    expect(items.length, equals(1));
    expect(items.first.id, equals('wide_epic_sunset_illustration'));
    expect(items.first.title, contains('Epic Sunset Illustration'));
    expect(
      items.first.fullUrl,
      equals(
        'https://wallpaperswide.com/download/epic_sunset_illustration-wallpaper-3840x2160.jpg',
      ),
    );
    expect(
      items.first.thumbUrl,
      equals(
        'https://hd.wallpaperswide.com/thumbs/epic_sunset_illustration-t1.jpg',
      ),
    );
    expect(items.first.sourceName, equals('wallpaperswide.com'));
  });

  test(
    'WallpapersWideSource handles empty or error response gracefully',
    () async {
      final mockClient = createMockHttpClient(
        responseBody: '',
        statusCode: 500,
      );

      final source = WallpapersWideSource(client: mockClient);
      final items = await source.fetchWallpapers(category: 'All', page: 1);
      expect(items, isEmpty);
    },
  );
}
