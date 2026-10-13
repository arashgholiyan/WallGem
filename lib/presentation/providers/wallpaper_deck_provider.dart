import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/i_wallpaper_repository.dart';

/// Presentation state controller managing the wallpaper swipe deck.
class WallpaperDeckProvider extends ChangeNotifier {
  final IWallpaperRepository _repository;

  final List<Wallpaper> _deck = [];
  final List<Wallpaper> _likedList = [];
  final List<Wallpaper> _historyStack = [];

  String _currentCategory = 'All';
  bool _isLoading = false;
  int _page = 1;

  WallpaperDeckProvider({required IWallpaperRepository repository})
    : _repository = repository;

  List<Wallpaper> get deck => List.unmodifiable(_deck);
  List<Wallpaper> get likedList => List.unmodifiable(_likedList);
  List<Wallpaper> get historyStack => List.unmodifiable(_historyStack);
  String get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;
  int get page => _page;
  bool get canUndo => _historyStack.isNotEmpty;
  Wallpaper? get topCard => _deck.isNotEmpty ? _deck.first : null;
  bool get isBatchComplete => _likedList.length >= AppConstants.batchTarget;

  /// Loads the first page of wallpapers.
  Future<void> loadInitialFeed() async {
    if (_isLoading) return;
    _isLoading = true;
    _deck.clear();
    _page = 1;
    notifyListeners();

    final items = await _repository.fetchWallpapers(
      category: _currentCategory,
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

  /// Fetches subsequent page without clearing current deck.
  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final items = await _repository.fetchWallpapers(
      category: _currentCategory,
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
}
