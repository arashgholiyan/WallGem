import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/wallpaper.dart';

/// Bottom thumbnail drawer displaying currently liked wallpapers towards batch completion.
class ThumbnailTray extends StatelessWidget {
  final List<Wallpaper> likedList;
  final void Function(Wallpaper)? onSelectWallpaper;

  const ThumbnailTray({
    super.key,
    required this.likedList,
    this.onSelectWallpaper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AppConstants.batchTarget, (index) {
          if (index < likedList.length) {
            final wallpaper = likedList[index];
            return Tooltip(
              message: '${wallpaper.title} (Click to preview)',
              child: MouseRegion(
                cursor: onSelectWallpaper != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: () => onSelectWallpaper?.call(wallpaper),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 44,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.like, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.thumbUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
