import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';

/// High-resolution curated catalog providing offline readiness and fallback reliability.
class CuratedWallpaperSource {
  CuratedWallpaperSource._();

  static List<WallpaperModel> getCuratedWallpapers() {
    return const [
      WallpaperModel(
        id: 'curated_cyberpunk_neon',
        title: 'Neon Megacity Skyline',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl: 'https://picsum.photos/id/1015/800/450',
        fullUrl: 'https://picsum.photos/id/1015/3840/2160',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'Cyberpunk',
        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
      ),
      WallpaperModel(
        id: 'curated_obsidian_peaks',
        title: 'Midnight Obsidian Mountain Peak',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl: 'https://picsum.photos/id/1025/800/450',
        fullUrl: 'https://picsum.photos/id/1025/3840/2160',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'OLED Dark',
        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
      ),
      WallpaperModel(
        id: 'curated_emerald_valley',
        title: 'Emerald Pine Mist Valley',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl: 'https://picsum.photos/id/1036/800/450',
        fullUrl: 'https://picsum.photos/id/1036/3840/2160',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'Landscape',
        colors: [Color(0xFF166534), Color(0xFF86EFAC)],
      ),
      WallpaperModel(
        id: 'curated_pacific_ocean',
        title: 'Pacific Blue Ocean Ridge',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl: 'https://picsum.photos/id/1043/800/450',
        fullUrl: 'https://picsum.photos/id/1043/3840/2160',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'Landscape',
        colors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
      ),
      WallpaperModel(
        id: 'curated_shinkai_sunset',
        title: 'Twilight Anime Skyline',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl: 'https://picsum.photos/id/1074/800/450',
        fullUrl: 'https://picsum.photos/id/1074/3840/2160',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'Anime',
        colors: [Color(0xFF6366F1), Color(0xFFF43F5E)],
      ),
      WallpaperModel(
        id: 'curated_cosmic_nebula',
        title: 'Carina Deep Cosmic Vistas',
        author: 'Wall Gem Curated',
        sourceName: 'Curated UHD',
        thumbUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Carina_Nebula_%28NGC_3372%29_by_ESO.jpg/800px-Carina_Nebula_%28NGC_3372%29_by_ESO.jpg',
        fullUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/b5/Carina_Nebula_%28NGC_3372%29_by_ESO.jpg',
        resolution: '3840x2160 (4K UHD)',
        ratio: '16:9',
        category: 'Space',
        colors: [Color(0xFF1E1B4B), Color(0xFFF59E0B)],
      ),
    ];
  }
}
