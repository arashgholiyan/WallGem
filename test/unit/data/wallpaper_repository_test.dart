import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/curated_wallpaper_source.dart';
import 'package:wall_gem/data/repositories/wallpaper_repository_impl.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('CuratedWallpaperSource contains fallback wallpapers', () {
    final curated = CuratedWallpaperSource.getCuratedWallpapers();
    expect(curated.length, greaterThanOrEqualTo(5));
    expect(curated.first.resolution, contains('4K'));
  });

  test(
    'WallpaperRepositoryImpl combines sources and falls back reliably',
    () async {
      // When remote sources fail with 500, repository falls back to curated
      final mockClient = createMockHttpClient(
        responseBody: '',
        statusCode: 500,
      );
      final repo = WallpaperRepositoryImpl(client: mockClient);

      final feed = await repo.fetchWallpapers(category: 'All', page: 1);
      expect(feed.isNotEmpty, isTrue);
    },
  );

  test('WallpaperRepositoryImpl routes to specific source platform', () async {
    const mockWideHtml = '''
        <img src="https://hd.wallpaperswide.com/thumbs/sample_nature-t1.jpg" alt="Sample Nature" />
      ''';
    final mockClient = createMockHttpClient(
      responseBody: mockWideHtml,
      statusCode: 200,
    );
    final repo = WallpaperRepositoryImpl(client: mockClient);

    final feed = await repo.fetchWallpapers(
      category: 'Landscape',
      source: 'WallpapersWide',
      page: 1,
    );
    expect(feed.isNotEmpty, isTrue);
    expect(feed.first.sourceName, equals('wallpaperswide.com'));
  });
}
