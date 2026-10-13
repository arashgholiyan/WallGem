import 'package:flutter/material.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom action dock with circular action buttons and keyboard hint labels.
class ActionDock extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onStar;
  final VoidCallback onUndo;
  final VoidCallback onPreview;
  final bool canUndo;

  const ActionDock({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onStar,
    required this.onUndo,
    required this.onPreview,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: AppKeys.actionDock,
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo (Z)
          _buildActionButton(
            key: AppKeys.undoButton,
            icon: Icons.replay,
            color: canUndo ? AppColors.secondary : AppColors.textMuted,
            size: 48,
            onTap: canUndo ? onUndo : null,
            tooltip: 'Undo (Z)',
          ),
          const SizedBox(width: 16),

          // Pass (←)
          _buildActionButton(
            key: AppKeys.passButton,
            icon: Icons.close,
            color: AppColors.pass,
            size: 64,
            onTap: onPass,
            tooltip: 'Pass (Left Arrow)',
          ),
          const SizedBox(width: 16),

          // Apply Wallpaper (↑)
          _buildActionButton(
            key: AppKeys.starButton,
            icon: Icons.wallpaper_rounded,
            color: AppColors.star,
            size: 52,
            onTap: onStar,
            tooltip: 'Set as Desktop Wallpaper (Up Arrow)',
          ),
          const SizedBox(width: 16),

          // Preview (Space)
          _buildActionButton(
            key: AppKeys.previewButton,
            icon: Icons.remove_red_eye_outlined,
            color: AppColors.cyan,
            size: 48,
            onTap: onPreview,
            tooltip: 'Inspect Preview (Space)',
          ),
          const SizedBox(width: 16),

          // Like (→)
          _buildActionButton(
            key: AppKeys.likeButton,
            icon: Icons.favorite,
            color: AppColors.like,
            size: 64,
            onTap: onLike,
            tooltip: 'Like (Right Arrow)',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Key key,
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC12151F),
            border: Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
    );
  }
}
