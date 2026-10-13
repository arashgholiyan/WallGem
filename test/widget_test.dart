import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/main.dart';

class StubRepository implements IWallpaperRepository {
  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    int page = 1,
  }) async {
    return [
      const Wallpaper(
        id: 'stub_test',
        title: 'Cyber Deck Test',
        author: 'Wall Gem Studio',
        sourceName: 'wallhaven.cc',
        thumbUrl: 'https://example.com/thumb.jpg',
        fullUrl: 'https://example.com/full.jpg',
        resolution: '3840x2160',
        aspectRatio: '16:9',
        category: 'Cyberpunk',
        dominantColors: [Colors.indigo],
      ),
    ];
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query) async => [];
}

void main() {
  testWidgets('App smoke test initializes and renders Wall Gem', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      WallGemApp(
        wallpaperRepository: StubRepository(),
        wallpaperService: NoopWallpaperService(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Wall Gem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
