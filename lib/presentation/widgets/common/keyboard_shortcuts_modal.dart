import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_shortcuts.dart';

/// Glassmorphic Keyboard Shortcuts cheatsheet modal inspired by Raycast and 21st.dev.
class KeyboardShortcutsModal extends StatelessWidget {
  const KeyboardShortcutsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => const KeyboardShortcutsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchShortcut = PlatformShortcuts.searchBadge;
    final isMac = Platform.isMacOS;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        child: Container(
          width: 580,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFA161A28), Color(0xFA0F121C)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.keyboard_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Keyboard Shortcuts',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    isMac
                                        ? 'macOS Desktop Keybindings'
                                        : 'Desktop Ergonomics & Hotkeys',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            tooltip: 'Close (Esc)',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 1: Deck Navigation
                      _buildSectionTitle('🃏 Swipe Deck Navigation'),
                      const SizedBox(height: 8),
                      _buildShortcutRow(
                        keyBadge: '→',
                        title: 'Like Wallpaper',
                        description: 'Saves to local Favorites Vault and batch',
                      ),
                      _buildShortcutRow(
                        keyBadge: '←',
                        title: 'Pass Wallpaper',
                        description: 'Dismisses card to history stack',
                      ),
                      _buildShortcutRow(
                        keyBadge: '↑',
                        title: 'Apply Instantly',
                        description:
                            'Sets as desktop background with zero delay',
                      ),
                      _buildShortcutRow(
                        keyBadge: 'Z',
                        title: 'Undo Pass',
                        description: 'Restores the previous card from history',
                      ),
                      _buildShortcutRow(
                        keyBadge: 'Space',
                        title: 'Inspect Preview',
                        description:
                            'Opens 4K Lightbox, Palette Exporter & Splitter',
                      ),
                      _buildShortcutRow(
                        keyBadge: 'R',
                        title: 'Refresh Batch',
                        description: 'Fetches new batch from current platform',
                      ),
                      const SizedBox(height: 18),

                      // Section 2: Vault & Search
                      _buildSectionTitle('🏛️ Favorites Vault & Search'),
                      const SizedBox(height: 8),
                      _buildShortcutRow(
                        keyBadge: searchShortcut,
                        title: 'Focus Search',
                        description: 'Instantly highlights search input',
                      ),
                      _buildShortcutRow(
                        keyBadge: '/',
                        title: 'Quick Search',
                        description:
                            'Universal slash shortcut to search favorites',
                      ),
                      _buildShortcutRow(
                        keyBadge: 'Esc',
                        title: 'Clear / Return',
                        description:
                            'Clears search keyword, or returns to Deck',
                      ),
                      const SizedBox(height: 18),

                      // Section 3: General & Modals
                      _buildSectionTitle('⚡ General Controls'),
                      const SizedBox(height: 8),
                      _buildShortcutRow(
                        keyBadge: '?',
                        altBadge: 'F1',
                        title: 'Keyboard Cheatsheet',
                        description: 'Opens this shortcuts dialog',
                      ),
                      _buildShortcutRow(
                        keyBadge: 'Esc',
                        title: 'Dismiss Dialog',
                        description: 'Closes any active modal or preview',
                      ),

                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Press Esc or click anywhere outside to close',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.cyan,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildShortcutRow({
    required String keyBadge,
    String? altBadge,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildKeyBadge(keyBadge),
              if (altBadge != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildKeyBadge(altBadge),
              ],
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBadge(String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
