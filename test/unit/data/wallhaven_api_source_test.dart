import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/wallhaven_api_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test(
    'WallhavenApiSource returns parsed wallpaper models on HTTP 200',
    () async {
      final mockClient = createMockHttpClient(
        responseBody:
            '{"data":[{"id":"1","path":"https://full.jpg","thumbs":{"large":"https://thumb.jpg"},"resolution":"3840x2160","ratio":"16:9","category":"general","colors":["#ffffff"],"uploader":{"username":"TopArtist"}}]}',
        statusCode: 200,
      );

      final source = WallhavenApiSource(client: mockClient);
      final items = await source.fetchWallpapers(category: 'All', page: 1);

      expect(items.length, equals(1));
      expect(items.first.id, equals('wallhaven_1'));
      expect(items.first.author, equals('TopArtist'));
    },
  );

  test(
    'WallhavenApiSource returns empty list on network error gracefully',
    () async {
      final mockClient = createMockHttpClient(
        responseBody: '',
        statusCode: 500,
      );
      final source = WallhavenApiSource(client: mockClient);
      final items = await source.fetchWallpapers(category: 'All', page: 1);
      expect(items, isEmpty);
    },
  );
}
