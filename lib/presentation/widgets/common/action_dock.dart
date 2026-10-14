import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_keys.dart';
import '../../../core/theme/app_colors.dart';

/// Floating frosted glass action dock with animated hover micro-interactions
/// and sleek keyboard shortcut hints.
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
      padding: const EdgeInsets.only(bottom: 16, top: 6),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xD9131726), Color(0xEA0D101A)],
                ),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Undo (Z)
                  _DockButton(
                    buttonKey: AppKeys.undoButton,
                    icon: Icons.replay_rounded,
                    color: canUndo ? AppColors.secondary : AppColors.textMuted,
                    size: 46,
                    onTap: canUndo ? onUndo : null,
                    tooltip: 'Undo (Z)',
                    kbdHint: 'Z',
                  ),
                  const SizedBox(width: 14),

                  // Pass (←)
                  _DockButton(
                    buttonKey: AppKeys.passButton,
                    icon: Icons.close_rounded,
                    color: AppColors.pass,
                    size: 58,
                    onTap: onPass,
                    tooltip: 'Pass (Left Arrow)',
                    kbdHint: '←',
                  ),
                  const SizedBox(width: 14),

                  // Apply Wallpaper (↑)
                  _DockButton(
                    buttonKey: AppKeys.starButton,
                    icon: Icons.wallpaper_rounded,
                    color: AppColors.star,
                    size: 52,
                    onTap: onStar,
                    tooltip: 'Set as Desktop Wallpaper (Up Arrow)',
                    kbdHint: '↑',
                    isProminent: true,
                  ),
                  const SizedBox(width: 14),

                  // Preview (Space)
                  _DockButton(
                    buttonKey: AppKeys.previewButton,
                    icon: Icons.remove_red_eye_outlined,
                    color: AppColors.cyan,
                    size: 46,
                    onTap: onPreview,
                    tooltip: 'Inspect Preview (Space)',
                    kbdHint: 'Space',
                  ),
                  const SizedBox(width: 14),

                  // Like (→)
                  _DockButton(
                    buttonKey: AppKeys.likeButton,
                    icon: Icons.favorite_rounded,
                    color: AppColors.like,
                    size: 58,
                    onTap: onLike,
                    tooltip: 'Like (Right Arrow)',
                    kbdHint: '→',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatefulWidget {
  final Key buttonKey;
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final String tooltip;
  final String kbdHint;
  final bool isProminent;

  const _DockButton({
    required this.buttonKey,
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    required this.tooltip,
    required this.kbdHint,
    this.isProminent = false,
  });

  @override
  State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final activeColor = isEnabled ? widget.color : AppColors.textMuted;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _isHovered && isEnabled ? 1.09 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isProminent && isEnabled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withValues(
                              alpha: _isHovered ? 0.35 : 0.22,
                            ),
                            const Color(0xDD121522),
                          ],
                        )
                      : null,
                  color: widget.isProminent ? null : const Color(0xDD121522),
                  border: Border.all(
                    color: _isHovered && isEnabled
                        ? activeColor.withValues(alpha: 0.8)
                        : (widget.isProminent && isEnabled
                              ? activeColor.withValues(alpha: 0.6)
                              : activeColor.withValues(alpha: 0.35)),
                    width: widget.isProminent ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (_isHovered && isEnabled)
                      BoxShadow(
                        color: activeColor.withValues(
                          alpha: widget.isProminent ? 0.45 : 0.3,
                        ),
                        blurRadius: widget.isProminent ? 24 : 18,
                        spreadRadius: widget.isProminent ? 2 : 1,
                      )
                    else if (widget.isProminent && isEnabled)
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: widget.buttonKey,
                    onTap: widget.onTap,
                    customBorder: const CircleBorder(),
                    splashColor: activeColor.withValues(alpha: 0.2),
                    highlightColor: activeColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: activeColor,
                        size: widget.size * 0.44,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Sleek KBD micro hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
              child: Text(
                widget.kbdHint,
                style: TextStyle(
                  color: isEnabled
                      ? AppColors.textSecondary.withValues(alpha: 0.85)
                      : AppColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
