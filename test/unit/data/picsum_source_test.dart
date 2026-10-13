import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/picsum_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('PicsumSource parses 5K items into WallpaperModels', () async {
    const sampleJson = '''
      [
        {
          "id": "10",
          "author": "Paul Jarvis",
          "width": 5000,
          "height": 3333,
          "url": "https://unsplash.com/photos/6J--NXulQCs",
          "download_url": "https://picsum.photos/id/10/5000/3333"
        }
      ]
    ''';

    final mockClient = createMockHttpClient(
      responseBody: sampleJson,
      statusCode: 200,
    );

    final source = PicsumSource(client: mockClient);
    final items = await source.fetchWallpapers(page: 1);

    expect(items.length, equals(1));
    expect(items.first.id, equals('picsum_10'));
    expect(items.first.author, equals('Paul Jarvis'));
    expect(
      items.first.fullUrl,
      equals('https://picsum.photos/id/10/5000/3333'),
    );
    expect(items.first.sourceName, contains('picsum.photos'));
  });

  test('PicsumSource handles network error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = PicsumSource(client: mockClient);
    final items = await source.fetchWallpapers(page: 1);
    expect(items, isEmpty);
  });
}
