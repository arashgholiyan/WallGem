import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wall_gem/core/theme/desktop_scroll_behavior.dart';
import 'package:wall_gem/core/utils/platform_shortcuts.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/entities/favorite_wallpaper.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_favorites_repository.dart';
import 'package:wall_gem/presentation/providers/favorites_provider.dart';
import 'package:wall_gem/presentation/providers/wallpaper_action_provider.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';
import 'package:wall_gem/presentation/widgets/batch/batch_complete_dialog.dart';
import 'package:wall_gem/presentation/widgets/common/header_bar.dart';
import 'package:wall_gem/presentation/widgets/palette/palette_export_modal.dart';
import 'package:wall_gem/presentation/widgets/preview/wallpaper_preview_dialog.dart';
import 'package:wall_gem/presentation/widgets/vault/favorites_vault_view.dart';

class StubFavoritesRepository implements IFavoritesRepository {
  final List<FavoriteWallpaper> items = [];

  @override
  Future<List<FavoriteWallpaper>> loadFavorites() async => List.from(items);

  @override
  Future<void> saveFavorite(Wallpaper wallpaper, {String? localPath}) async {
    items.removeWhere((f) => f.id == wallpaper.id);
    items.add(
      FavoriteWallpaper.fromWallpaper(wallpaper, localFilePath: localPath),
    );
  }

  @override
  Future<void> removeFavorite(String id) async {
    items.removeWhere((f) => f.id == id);
  }

  @override
  Future<bool> isFavorite(String id) async => items.any((f) => f.id == id);
}

void main() {
  group('PlatformShortcuts & DesktopScrollBehavior', () {
    test('PlatformShortcuts provides appropriate badges and labels', () {
      expect(PlatformShortcuts.searchBadge, isNotEmpty);
      expect(PlatformShortcuts.modifierKey, isNotEmpty);
      expect(PlatformShortcuts.slideshowPlatformLabel, isNotEmpty);
      expect(
        PlatformShortcuts.searchTooltip,
        contains(PlatformShortcuts.searchBadge),
      );
    });

    testWidgets(
      'DesktopScrollBehavior enables mouse drag and bouncing physics',
      (WidgetTester tester) async {
        const behavior = DesktopScrollBehavior();
        expect(behavior.dragDevices, contains(PointerDeviceKind.mouse));
        expect(behavior.dragDevices, contains(PointerDeviceKind.trackpad));
        expect(behavior.dragDevices, contains(PointerDeviceKind.touch));

        await tester.pumpWidget(
          MaterialApp(
            scrollBehavior: behavior,
            home: Builder(
              builder: (context) {
                final physics = behavior.getScrollPhysics(context);
                expect(physics, isA<BouncingScrollPhysics>());
                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  });

  group('Modal ESC Key Dismissal', () {
    const testWallpaper = Wallpaper(
      id: 'preview_1',
      title: 'Neon Horizon',
      author: 'CyberArtist',
      sourceName: 'Curated',
      thumbUrl: 'https://example.com/thumb.jpg',
      fullUrl: 'https://example.com/full.jpg',
      resolution: '3840x2160',
      aspectRatio: '16:9',
      category: 'Cyberpunk',
      dominantColors: [Colors.purple, Colors.cyan],
    );

    testWidgets('WallpaperPreviewDialog closes when ESC is pressed', (
      WidgetTester tester,
    ) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => WallpaperPreviewDialog(
                      wallpaper: testWallpaper,
                      onApply: () {},
                    ),
                  ).then((_) => closed = true);
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(WallpaperPreviewDialog), findsOneWidget);

      // Press ESC key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(WallpaperPreviewDialog), findsNothing);
      expect(closed, isTrue);
    });

    testWidgets('PaletteExportModal closes when ESC is pressed', (
      WidgetTester tester,
    ) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) =>
                        const PaletteExportModal(wallpaper: testWallpaper),
                  ).then((_) => closed = true);
                },
                child: const Text('Open Palette'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Palette'));
      await tester.pumpAndSettle();

      expect(find.byType(PaletteExportModal), findsOneWidget);

      // Press ESC key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(PaletteExportModal), findsNothing);
      expect(closed, isTrue);
    });

    testWidgets('BatchCompleteDialog invokes onContinue when ESC is pressed', (
      WidgetTester tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => BatchCompleteDialog(
                      batch: const [testWallpaper],
                      onOpenFolder: () {},
                      onContinue: () {
                        dismissed = true;
                        Navigator.of(ctx).pop();
                      },
                    ),
                  );
                },
                child: const Text('Open Batch'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Batch'));
      await tester.pumpAndSettle();

      expect(find.byType(BatchCompleteDialog), findsOneWidget);

      // Press ESC key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(BatchCompleteDialog), findsNothing);
      expect(dismissed, isTrue);
    });
  });

  group('FavoritesVaultView Platform Shortcuts & Responsive Scaling', () {
    testWidgets('FavoritesVaultView displays dynamic platform shortcut badge', (
      WidgetTester tester,
    ) async {
      final repo = StubFavoritesRepository();
      final favProvider = FavoritesProvider(repository: repo);
      final actionProvider = WallpaperActionProvider(
        service: NoopWallpaperService(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<WallpaperActionProvider>.value(
              value: actionProvider,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: FavoritesVaultView())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(PlatformShortcuts.searchBadge), findsOneWidget);
    });

    testWidgets('FavoritesVaultView clears search and unfocuses on Escape', (
      WidgetTester tester,
    ) async {
      final repo = StubFavoritesRepository();
      final favProvider = FavoritesProvider(repository: repo);
      final actionProvider = WallpaperActionProvider(
        service: NoopWallpaperService(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
            ChangeNotifierProvider<WallpaperActionProvider>.value(
              value: actionProvider,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: FavoritesVaultView())),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Cyberpunk');
      await tester.pumpAndSettle();

      expect(favProvider.searchKeyword, equals('Cyberpunk'));

      // Press ESC key -> clears search text
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(favProvider.searchKeyword, isEmpty);
    });

    testWidgets(
      'FavoritesVaultView grid scales cleanly to 7 columns on ultrawide 3440px viewport',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(3440, 1440);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repo = StubFavoritesRepository();
        for (int i = 0; i < 8; i++) {
          await repo.saveFavorite(
            Wallpaper(
              id: 'uw_$i',
              title: 'Ultrawide Wall $i',
              author: 'Artist',
              sourceName: 'Curated',
              thumbUrl: 'https://example.com/thumb$i.jpg',
              fullUrl: 'https://example.com/full$i.jpg',
              resolution: '5120x2160',
              aspectRatio: '21:9',
              category: 'Cyberpunk',
              dominantColors: const [Colors.blue],
            ),
          );
        }

        final favProvider = FavoritesProvider(repository: repo);
        final actionProvider = WallpaperActionProvider(
          service: NoopWallpaperService(),
        );
        await favProvider.loadFavorites();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FavoritesProvider>.value(
                value: favProvider,
              ),
              ChangeNotifierProvider<WallpaperActionProvider>.value(
                value: actionProvider,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: FavoritesVaultView()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);

        final gridView = tester.widget<GridView>(gridFinder);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(7));
      },
    );
  });

  group('HeaderBar Desktop Cursor & Batch Action Ergonomics', () {
    testWidgets(
      'HeaderBar batch progress pill is clickable and calls onOpenFolder',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        bool folderOpened = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HeaderBar(
                likedCount: 4,
                activeSource: 'All Sources',
                onSelectSource: (_) {},
                onOpenFolder: () => folderOpened = true,
                activeViewMode: ViewMode.deck,
                favoritesCount: 3,
              ),
            ),
          ),
        );

        // Tap batch counter pill
        await tester.tap(find.text('4 / 5'));
        await tester.pumpAndSettle();

        expect(folderOpened, isTrue);
      },
    );
  });
}
