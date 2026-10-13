import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';

/// Responsive, overflow-safe top navigation bar.
class HeaderBar extends StatelessWidget {
  final int likedCount;
  final VoidCallback onOpenFolder;

  const HeaderBar({
    super.key,
    required this.likedCount,
    required this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (likedCount / AppConstants.batchTarget).clamp(0.0, 1.0);

    return Container(
      key: AppKeys.headerBar,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xCC12151F),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & App Title
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Color(0x666366F1), blurRadius: 12),
                        ],
                      ),
                      child: const Center(
                        child: Text('💎', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x336366F1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0x666366F1)),
                        ),
                        child: const Text(
                          '4K UHD',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Batch Progress Bar & Folder Launcher
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: isCompact ? 60 : 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.like,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$likedCount / ${AppConstants.batchTarget}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.like,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.folder_open_outlined,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Open Wallpaper Folder',
                    onPressed: onOpenFolder,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
