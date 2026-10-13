import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/alphacoders_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test(
    'AlphaCodersSource parses meta contentUrl into WallpaperModels',
    () async {
      const sampleHtml = '''
      <html><head>
        <meta itemprop="contentUrl" content="https://images5.alphacoders.com/141/1415928.png">
        <meta itemprop="thumbnailUrl" content="https://images5.alphacoders.com/141/thumb-350-1415928.webp">
      </head><body></body></html>
    ''';

      final mockClient = createMockHttpClient(
        responseBody: sampleHtml,
        statusCode: 200,
      );

      final source = AlphaCodersSource(client: mockClient);
      final items = await source.fetchWallpapers(category: 'Gaming', page: 1);

      expect(items.length, equals(1));
      expect(items.first.id, equals('alpha_1415928'));
      expect(
        items.first.fullUrl,
        equals('https://images5.alphacoders.com/141/1415928.png'),
      );
      expect(
        items.first.thumbUrl,
        equals('https://images5.alphacoders.com/141/thumb-350-1415928.webp'),
      );
      expect(items.first.sourceName, equals('alphacoders.com'));
    },
  );

  test('AlphaCodersSource handles failure gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 404);

    final source = AlphaCodersSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);
    expect(items, isEmpty);
  });
}
