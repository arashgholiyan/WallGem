import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/day_night_calculator.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/i_wallpaper_repository.dart';

/// Top-level view mode switching between the 3D Deck and Favorites Vault.
enum ViewMode { deck, vault }

/// Presentation state controller managing the wallpaper swipe deck,
/// Day/Night Sun cycle dynamic categories, and auto-cycler background timer.
class WallpaperDeckProvider extends ChangeNotifier {
  final IWallpaperRepository _repository;

  final List<Wallpaper> _deck = [];
  final List<Wallpaper> _likedList = [];
  final List<Wallpaper> _historyStack = [];

  ViewMode _viewMode = ViewMode.deck;
  String _currentCategory = 'All';
  String _currentSource = 'All Sources';
  bool _isLoading = false;
  int _page = 1;

  bool _isDayNightModeEnabled = false;
  Duration? _autoCycleInterval;
  Timer? _cycleTimer;

  WallpaperDeckProvider({required IWallpaperRepository repository})
    : _repository = repository;

  List<Wallpaper> get deck => List.unmodifiable(_deck);
  List<Wallpaper> get likedList => List.unmodifiable(_likedList);
  List<Wallpaper> get historyStack => List.unmodifiable(_historyStack);
  ViewMode get viewMode => _viewMode;
  String get currentCategory => _currentCategory;
  String get currentSource => _currentSource;
  bool get isLoading => _isLoading;
  int get page => _page;
  bool get canUndo => _historyStack.isNotEmpty;
  Wallpaper? get topCard => _deck.isNotEmpty ? _deck.first : null;
  bool get isBatchComplete => _likedList.length >= AppConstants.batchTarget;
  bool get isDayNightModeEnabled => _isDayNightModeEnabled;
  Duration? get autoCycleInterval => _autoCycleInterval;

  /// Changes the primary view between 3D Swipe Deck and Favorites Vault.
  void setViewMode(ViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  /// Toggles day/night sun cycle mode. When enabled, automatically applies
  /// intelligent category recommendations ('Landscape' vs 'OLED Dark').
  Future<void> toggleDayNightMode() async {
    _isDayNightModeEnabled = !_isDayNightModeEnabled;
    if (_isDayNightModeEnabled) {
      final recommended = DayNightCalculator.getRecommendedCategory(
        DateTime.now(),
      );
      await setCategory(recommended);
    } else {
      notifyListeners();
    }
  }

  /// Configures or disables the automatic wallpaper cycling slideshow timer.
  void setAutoCycleInterval(Duration? interval, {VoidCallback? onCycle}) {
    _cycleTimer?.cancel();
    _cycleTimer = null;
    _autoCycleInterval = interval;

    if (interval != null) {
      _cycleTimer = Timer.periodic(interval, (_) {
        if (onCycle != null) {
          onCycle();
        } else {
          swipeLeft();
        }
      });
    }
    notifyListeners();
  }

  /// Loads the first page of wallpapers.
  Future<void> loadInitialFeed() async {
    if (_isLoading) return;
    _isLoading = true;
    _deck.clear();
    _page = 1;
    notifyListeners();

    final items = await _repository.fetchWallpapers(
      category: _currentCategory,
      source: _currentSource,
      page: _page,
    );

    _deck.addAll(items);
    _isLoading = false;
    _page++;
    notifyListeners();
  }

  /// Changes category filter and refreshes feed.
  Future<void> setCategory(String category) async {
    if (_currentCategory == category && _deck.isNotEmpty) return;
    _currentCategory = category;
    await loadInitialFeed();
  }

  /// Changes source platform filter and refreshes feed.
  Future<void> setSource(String source) async {
    if (_currentSource == source && _deck.isNotEmpty) return;
    _currentSource = source;
    await loadInitialFeed();
  }

  /// Fetches subsequent page without clearing current deck.
  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final items = await _repository.fetchWallpapers(
      category: _currentCategory,
      source: _currentSource,
      page: _page,
    );

    _deck.addAll(items);
    _isLoading = false;
    _page++;
    notifyListeners();
  }

  /// Swiping Right: Like wallpaper.
  Wallpaper? swipeRight() {
    if (_deck.isEmpty) return null;
    final item = _deck.removeAt(0);
    _likedList.add(item);
    _historyStack.add(item);
    _checkDeckReplenishment();
    notifyListeners();
    return item;
  }

  /// Swiping Left: Pass wallpaper.
  Wallpaper? swipeLeft() {
    if (_deck.isEmpty) return null;
    final item = _deck.removeAt(0);
    _historyStack.add(item);
    _checkDeckReplenishment();
    notifyListeners();
    return item;
  }

  /// Swiping Up / Star: Like and trigger wallpaper application.
  Wallpaper? swipeUp() {
    if (_deck.isEmpty) return null;
    final item = _deck.removeAt(0);
    _likedList.add(item);
    _historyStack.add(item);
    _checkDeckReplenishment();
    notifyListeners();
    return item;
  }

  /// Undo last swipe gesture.
  Wallpaper? undo() {
    if (_historyStack.isEmpty) return null;
    final lastItem = _historyStack.removeLast();
    _likedList.remove(lastItem);
    _deck.insert(0, lastItem);
    notifyListeners();
    return lastItem;
  }

  /// Clears the liked list (e.g. after batch completion dialog dismissed).
  void clearLikedList() {
    _likedList.clear();
    notifyListeners();
  }

  void _checkDeckReplenishment() {
    if (_deck.length < 5 && !_isLoading) {
      loadMore();
    }
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }
}
