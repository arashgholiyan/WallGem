import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/fourk_wallpapers_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test(
    'FourKWallpapersSource parses HTML and builds 4K UHD download links',
    () async {
      const sampleHtml = '''
      <html><body>
        <div class="wallpapers__item">
          <a title="Koenigsegg Supercar" href="/cars/koenigsegg-supercar-27356.html">
            <img itemprop="thumbnail" src="/images/walls/thumbs/27356.jpg" alt="Koenigsegg CCGT, Supercar" />
          </a>
        </div>
      </body></html>
    ''';

      final mockClient = createMockHttpClient(
        responseBody: sampleHtml,
        statusCode: 200,
      );

      final source = FourKWallpapersSource(client: mockClient);
      final items = await source.fetchWallpapers(category: 'Cars', page: 1);

      expect(items.length, equals(1));
      expect(items.first.id, equals('4kwall_27356'));
      expect(
        items.first.fullUrl,
        equals(
          'https://4kwallpapers.com/images/wallpapers/koenigsegg-supercar-3840x2160-27356.jpg',
        ),
      );
      expect(
        items.first.thumbUrl,
        equals('https://4kwallpapers.com/images/walls/thumbs_2t/27356.jpg'),
      );
      expect(items.first.sourceName, equals('4kwallpapers.com'));
    },
  );

  test('FourKWallpapersSource handles error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);

    final source = FourKWallpapersSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);
    expect(items, isEmpty);
  });
}
