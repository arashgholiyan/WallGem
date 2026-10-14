import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/wallpaper_repository_impl.dart';
import 'data/services/favorites_storage_service.dart';
import 'data/services/wallpaper_service_factory.dart';
import 'domain/repositories/i_favorites_repository.dart';
import 'domain/repositories/i_wallpaper_repository.dart';
import 'domain/services/i_wallpaper_service.dart';
import 'core/theme/desktop_scroll_behavior.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/wallpaper_action_provider.dart';
import 'presentation/providers/wallpaper_deck_provider.dart';
import 'presentation/views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Universal cross-platform desktop service (Windows, macOS, Linux)
  final IWallpaperPlatformService wallpaperService =
      WallpaperServiceFactory.create();

  final IWallpaperRepository wallpaperRepository = WallpaperRepositoryImpl();
  final IFavoritesRepository favoritesRepository = FavoritesRepositoryImpl(
    storageService: FavoritesStorageService(),
  );

  runApp(
    WallGemApp(
      wallpaperRepository: wallpaperRepository,
      wallpaperService: wallpaperService,
      favoritesRepository: favoritesRepository,
    ),
  );
}

/// Root application widget configuring theme and dependency providers.
class WallGemApp extends StatelessWidget {
  final IWallpaperRepository wallpaperRepository;
  final IWallpaperPlatformService wallpaperService;
  final IFavoritesRepository? favoritesRepository;

  const WallGemApp({
    super.key,
    required this.wallpaperRepository,
    required this.wallpaperService,
    this.favoritesRepository,
  });

  @override
  Widget build(BuildContext context) {
    final favRepo =
        favoritesRepository ??
        FavoritesRepositoryImpl(storageService: FavoritesStorageService());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WallpaperDeckProvider>(
          create: (_) => WallpaperDeckProvider(repository: wallpaperRepository),
        ),
        ChangeNotifierProvider<WallpaperActionProvider>(
          create: (_) => WallpaperActionProvider(service: wallpaperService),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(repository: favRepo),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        scrollBehavior: const DesktopScrollBehavior(),
        home: const HomeScreen(),
      ),
    );
  }
}
