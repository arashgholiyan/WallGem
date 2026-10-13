import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/presentation/providers/wallpaper_action_provider.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';
import 'package:wall_gem/presentation/views/home_screen.dart';

class StubWallpaperRepository implements IWallpaperRepository {
  @override
  Future<List<Wallpaper>> fetchWallpapers({
    required String category,
    String source = 'All Sources',
    int page = 1,
  }) async {
    return [
      const Wallpaper(
        id: 'stub_1',
        title: 'Neon Cyber City',
        author: 'Artist',
        sourceName: 'wallhaven.cc',
        thumbUrl: 'https://example.com/thumb.jpg',
        fullUrl: 'https://example.com/full.jpg',
        resolution: '3840x2160',
        aspectRatio: '16:9',
        category: 'Cyberpunk',
        dominantColors: [Colors.purple],
      ),
    ];
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query) async => [];
}

void main() {
  testWidgets(
    'HomeScreen renders without any RenderFlex overflow on 800x600 screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = StubWallpaperRepository();
      final deckProvider = WallpaperDeckProvider(repository: repo);
      final actionProvider = WallpaperActionProvider(
        service: NoopWallpaperService(),
      );
      await deckProvider.loadInitialFeed();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WallpaperDeckProvider>.value(
              value: deckProvider,
            ),
            ChangeNotifierProvider<WallpaperActionProvider>.value(
              value: actionProvider,
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Wall Gem'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('HomeScreen renders smoothly on large 1920x1080 display', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = StubWallpaperRepository();
    final deckProvider = WallpaperDeckProvider(repository: repo);
    final actionProvider = WallpaperActionProvider(
      service: NoopWallpaperService(),
    );
    await deckProvider.loadInitialFeed();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WallpaperDeckProvider>.value(
            value: deckProvider,
          ),
          ChangeNotifierProvider<WallpaperActionProvider>.value(
            value: actionProvider,
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Wall Gem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
