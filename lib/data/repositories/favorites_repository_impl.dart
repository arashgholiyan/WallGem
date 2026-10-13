import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/favorite_wallpaper.dart';
import '../../domain/repositories/i_favorites_repository.dart';
import '../services/favorites_storage_service.dart';

/// Implementation of [IFavoritesRepository] utilizing [FavoritesStorageService].
class FavoritesRepositoryImpl implements IFavoritesRepository {
  final FavoritesStorageService storageService;

  FavoritesRepositoryImpl({required this.storageService});

  @override
  Future<List<FavoriteWallpaper>> loadFavorites() async {
    return await storageService.loadFavorites();
  }

  @override
  Future<void> saveFavorite(Wallpaper wallpaper, {String? localPath}) async {
    final list = await storageService.loadFavorites();
    final updatedList = list.where((f) => f.id != wallpaper.id).toList();
    final newFavorite = FavoriteWallpaper.fromWallpaper(
      wallpaper,
      localFilePath: localPath,
    );
    updatedList.insert(0, newFavorite);
    await storageService.saveFavorites(updatedList);
  }

  @override
  Future<void> removeFavorite(String id) async {
    final list = await storageService.loadFavorites();
    final updatedList = list.where((f) => f.id != id).toList();
    await storageService.saveFavorites(updatedList);
  }

  @override
  Future<bool> isFavorite(String id) async {
    final list = await storageService.loadFavorites();
    return list.any((f) => f.id == id);
  }
}
