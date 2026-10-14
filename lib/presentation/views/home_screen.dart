import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/wallpaper.dart';
import '../providers/favorites_provider.dart';
import '../providers/wallpaper_action_provider.dart';
import '../providers/wallpaper_deck_provider.dart';
import '../widgets/batch/batch_complete_dialog.dart';
import '../widgets/common/action_dock.dart';
import '../widgets/common/category_selector.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/deck/swipeable_card_stack.dart';
import '../widgets/preview/wallpaper_preview_dialog.dart';
import '../widgets/thumbnail_tray.dart';
import '../widgets/common/keyboard_shortcuts_modal.dart';
import '../widgets/vault/favorites_vault_view.dart';

/// Primary application shell containing the responsive deck, Favorites Vault,
/// dock controls, and global keyboard shortcuts.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deck = context.read<WallpaperDeckProvider>();
      if (deck.deck.isEmpty && !deck.isLoading) {
        deck.loadInitialFeed().then((_) {
          if (mounted) _prefetchNextCards(deck.deck);
        });
      }

      final favs = context.read<FavoritesProvider?>();
      favs?.loadFavorites();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _prefetchNextCards(List<Wallpaper> deck) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (deck.length > 1) {
      // Precache full-res image for the immediate next card so it renders instantly
      precacheImage(CachedNetworkImageProvider(deck[1].fullUrl), context);
      for (int i = 1; i < min(4, deck.length); i++) {
        precacheImage(CachedNetworkImageProvider(deck[i].thumbUrl), context);
      }
    }
  }

  void _handleSwipeRight() {
    final item = context.read<WallpaperDeckProvider>().swipeRight();
    if (item != null) {
      context.read<FavoritesProvider?>()?.addFavorite(item);
      _checkBatchDialog();
    }
  }

  void _handleSwipeLeft() {
    context.read<WallpaperDeckProvider>().swipeLeft();
  }

  void _showApplyFeedback(bool success, String title) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success
            ? const Color(0xFF1E293B)
            : const Color(0xFF7F1D1D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: success
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Applied "$title" as desktop wallpaper!'
                    : 'Failed to set wallpaper. Please check permissions.',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSwipeUp() async {
    final item = context.read<WallpaperDeckProvider>().swipeUp();
    if (item != null) {
      context.read<FavoritesProvider?>()?.addFavorite(item);
      _checkBatchDialog();
      final success = await context
          .read<WallpaperActionProvider>()
          .applyAsWallpaper(item);
      _showApplyFeedback(success, item.title);
    }
  }

  void _handleUndo() {
    final undone = context.read<WallpaperDeckProvider>().undo();
    if (undone != null) {
      context.read<FavoritesProvider?>()?.removeFavorite(undone.id);
    }
  }

  void _checkBatchDialog() {
    final deckProvider = context.read<WallpaperDeckProvider>();
    final actionProvider = context.read<WallpaperActionProvider>();

    if (deckProvider.isBatchComplete && !_dialogOpen) {
      _dialogOpen = true;
      final currentBatch = List<Wallpaper>.from(deckProvider.likedList);
      actionProvider.saveBatchToDisk(currentBatch);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) => BatchCompleteDialog(
          batch: currentBatch,
          onOpenFolder: () {
            actionProvider.openFolder();
          },
          onContinue: () {
            Navigator.of(dialogCtx).pop();
            _dialogOpen = false;
            deckProvider.clearLikedList();
          },
        ),
      ).then((_) {
        _dialogOpen = false;
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _showPreview(Wallpaper wallpaper) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WallpaperPreviewDialog(
        wallpaper: wallpaper,
        onApply: () async {
          final success = await context
              .read<WallpaperActionProvider>()
              .applyAsWallpaper(wallpaper);
          _showApplyFeedback(success, wallpaper.title);
        },
      ),
    ).then((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = context.watch<WallpaperDeckProvider>();
    final actionProvider = context.watch<WallpaperActionProvider>();
    final favProvider = context.watch<FavoritesProvider?>();

    final isVault = deckProvider.viewMode == ViewMode.vault;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          // Guard: if primary focus is currently inside an EditableText (e.g. search bar), do not swallow hotkeys!
          final primaryFocus = FocusManager.instance.primaryFocus;
          final isEditingText = primaryFocus?.context?.widget is EditableText;
          if (isEditingText) return;

          // Help / Shortcuts Cheatsheet (? or F1)
          if (event.logicalKey == LogicalKeyboardKey.f1 ||
              event.character == '?' ||
              (HardwareKeyboard.instance.isShiftPressed &&
                  event.logicalKey == LogicalKeyboardKey.slash)) {
            KeyboardShortcutsModal.show(context).then((_) {
              if (mounted) _focusNode.requestFocus();
            });
            return;
          }

          if (!isVault) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _handleSwipeRight();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _handleSwipeLeft();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _handleSwipeUp();
            } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
              _handleUndo();
            } else if (event.logicalKey == LogicalKeyboardKey.space &&
                deckProvider.topCard != null) {
              _showPreview(deckProvider.topCard!);
            } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
              deckProvider.loadInitialFeed();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            deckProvider.setViewMode(ViewMode.deck);
            _focusNode.requestFocus();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient neon background glow
            Positioned(
              top: -150,
              left: MediaQuery.of(context).size.width / 2 - 300,
              child: Container(
                width: 600,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  HeaderBar(
                    likedCount: deckProvider.likedList.length,
                    activeSource: deckProvider.currentSource,
                    onSelectSource: (source) => deckProvider.setSource(source),
                    onOpenFolder: () => actionProvider.openFolder(),
                    activeViewMode: deckProvider.viewMode,
                    onSelectViewMode: (mode) {
                      deckProvider.setViewMode(mode);
                      if (mode == ViewMode.deck) {
                        _focusNode.requestFocus();
                      }
                    },
                    favoritesCount: favProvider?.favorites.length ?? 0,
                    isDayNightEnabled: deckProvider.isDayNightModeEnabled,
                    onToggleDayNight: () => deckProvider.toggleDayNightMode(),
                    autoCycleInterval: deckProvider.autoCycleInterval,
                    onSelectAutoCycleInterval: (interval) =>
                        deckProvider.setAutoCycleInterval(
                          interval,
                          onCycle: _handleSwipeUp,
                        ),
                    onShowShortcuts: () {
                      KeyboardShortcutsModal.show(context).then((_) {
                        if (mounted) _focusNode.requestFocus();
                      });
                    },
                  ),

                  // Vault View or Deck View
                  if (isVault)
                    const Expanded(child: FavoritesVaultView())
                  else ...[
                    CategorySelector(
                      activeCategory: deckProvider.currentCategory,
                      onSelectCategory: (category) =>
                          deckProvider.setCategory(category),
                    ),
                    Expanded(
                      child: Center(
                        child:
                            deckProvider.isLoading && deckProvider.deck.isEmpty
                            ? const Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : deckProvider.deck.isEmpty
                            ? _buildEmptyState(deckProvider)
                            : SwipeableCardStack(
                                deck: deckProvider.deck,
                                onSwipeLeft: _handleSwipeLeft,
                                onSwipeRight: _handleSwipeRight,
                                onSwipeUp: _handleSwipeUp,
                                onInspectPreview: () {
                                  if (deckProvider.topCard != null) {
                                    _showPreview(deckProvider.topCard!);
                                  }
                                },
                              ),
                      ),
                    ),
                    ThumbnailTray(
                      likedList: deckProvider.likedList,
                      onSelectWallpaper: (w) => _showPreview(w),
                    ),
                    ActionDock(
                      onPass: _handleSwipeLeft,
                      onLike: _handleSwipeRight,
                      onStar: _handleSwipeUp,
                      onUndo: _handleUndo,
                      onPreview: () {
                        if (deckProvider.topCard != null) {
                          _showPreview(deckProvider.topCard!);
                        }
                      },
                      canUndo: deckProvider.canUndo,
                    ),
                  ],
                ],
              ),
            ),

            // Floating Status HUD when applying wallpaper
            if (actionProvider.isApplying)
              Positioned(
                top: 76,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEE1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.cyan),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          actionProvider.statusMessage ??
                              'Applying desktop wallpaper...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(WallpaperDeckProvider deckProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text(
          'All caught up!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Discover more fresh high-resolution wallpapers',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Refresh Deck',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => deckProvider.loadInitialFeed(),
        ),
      ],
    );
  }
}
