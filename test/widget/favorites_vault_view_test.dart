import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/entities/favorite_wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_favorites_repository.dart';
import 'package:wall_gem/presentation/providers/favorites_provider.dart';
import 'package:wall_gem/presentation/providers/wallpaper_action_provider.dart';
import 'package:wall_gem/presentation/widgets/vault/favorites_vault_view.dart';

class StubFavoritesRepository implements IFavoritesRepository {
  final List<FavoriteWallpaper> items = [];

  @override
  Future<List<FavoriteWallpaper>> loadFavorites() async => List.from(items);

  @override
  Future<void> saveFavorite(Wallpaper wallpaper, {String? localPath}) async {
    items.removeWhere((f) => f.id == wallpaper.id);
    items.add(FavoriteWallpaper.fromWallpaper(wallpaper, localFilePath: localPath));
  }

  @override
  Future<void> removeFavorite(String id) async {
    items.removeWhere((f) => f.id == id);
  }

  @override
  Future<bool> isFavorite(String id) async => items.any((f) => f.id == id);
}

void main() {
  testWidgets('FavoritesVaultView renders empty state when no favorites exist', (
    WidgetTester tester,
  ) async {
    final repo = StubFavoritesRepository();
    final favProvider = FavoritesProvider(repository: repo);
    final actionProvider = WallpaperActionProvider(service: NoopWallpaperService());

    await favProvider.loadFavorites();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
          ChangeNotifierProvider<WallpaperActionProvider>.value(value: actionProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FavoritesVaultView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Vault is Empty'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('FavoritesVaultView renders cards and filters by keyword', (
    WidgetTester tester,
  ) async {
    final repo = StubFavoritesRepository();
    final sample1 = Wallpaper(
      id: 'w1',
      title: 'Neon Tokyo',
      author: 'Kavinsky',
      sourceName: 'Curated',
      thumbUrl: 'https://thumb1.jpg',
      fullUrl: 'https://full1.jpg',
      resolution: '3840x2160',
      aspectRatio: '16:9',
      category: 'Cyberpunk',
      dominantColors: const [Colors.purple],
    );
    final sample2 = Wallpaper(
      id: 'w2',
      title: 'Misty Mountains',
      author: 'Ansel',
      sourceName: 'Curated',
      thumbUrl: 'https://thumb2.jpg',
      fullUrl: 'https://full2.jpg',
      resolution: '3840x2160',
      aspectRatio: '16:9',
      category: 'Landscape',
      dominantColors: const [Colors.green],
    );

    await repo.saveFavorite(sample1);
    await repo.saveFavorite(sample2);

    final favProvider = FavoritesProvider(repository: repo);
    final actionProvider = WallpaperActionProvider(service: NoopWallpaperService());
    await favProvider.loadFavorites();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
          ChangeNotifierProvider<WallpaperActionProvider>.value(value: actionProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: FavoritesVaultView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Neon Tokyo'), findsOneWidget);
    expect(find.text('Misty Mountains'), findsOneWidget);

    // Enter search keyword
    await tester.enterText(find.byType(TextField), 'Tokyo');
    await tester.pumpAndSettle();

    expect(find.text('Neon Tokyo'), findsOneWidget);
    expect(find.text('Misty Mountains'), findsNothing);
  });
}
