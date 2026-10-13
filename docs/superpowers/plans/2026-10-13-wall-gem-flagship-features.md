# Wall Gem Flagship Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 5 community flagship features: Favorites Vault (JSON store + grid view), Dynamic Palette Exporter (Pywal, CSS, JSON), Day & Night Sun Cycle, Scheduled Auto-Cycler Timer, and Multi-Monitor Ultrawide Splitter.

**Architecture:** Layered Clean Architecture extending Domain models, concrete JSON and image services in the Data layer, reactive state controllers in Provider, and responsive Flutter presentation widgets with zero RenderFlex overflows.

**Tech Stack:** Flutter 3.38+ / Dart 3.10+, Provider, Http, Path, Services Clipboard, Flutter Test.

**Spec:** `docs/superpowers/specs/2026-10-13-wall-gem-flagship-features-design.md`

## Global Constraints

- Zero third-party proprietary database dependencies (use lightweight human-readable `favorites.json`).
- Zero RenderFlex overflows across any viewport dimension (>= 600px).
- Zero network requests in unit tests (hermetic mock clients).
- All file operations must handle missing directories and corrupted files gracefully without unhandled exceptions.
- 100% passing unit & widget test suite with zero analyzer warnings (`flutter analyze`).

## Review Focus

1. *Corrupted or missing `favorites.json`*: Storage service must recover gracefully and return an empty list without crashing.
2. *Auto-cycler timer active during app disposal*: Timer must be cleanly cancelled in `dispose()` to prevent memory leaks.
3. *Zero-item favorites state in Vault view*: Vault must display an inviting empty-state illustration prompting the user to like wallpapers.
4. *Window resize below 800px in Vault grid*: Grid must smoothly adapt between 2, 3, and 4 columns without layout clipping.
5. *Palette export on wallpaper without colors*: Formatter must fall back to elegant default accents rather than producing empty files.

---

### Task 1: Palette Formatter & Dynamic Color Engine

**Files:**
- Create: `lib/data/services/palette_format_service.dart`
- Test: `test/unit/data/palette_format_service_test.dart`

**Interfaces:**
- Produces `PaletteFormatService` with static methods:
  - `toPywal(List<Color> colors)` -> String (Pywal `.Xresources` format)
  - `toCssVariables(List<Color> colors)` -> String (CSS `:root` variables)
  - `toJson(List<Color> colors)` -> String (JSON object)
  - `toHexCsv(List<Color> colors)` -> String (Comma-separated hex codes)

- [ ] **Step 1: Write the failing test**
  - Create `test/unit/data/palette_format_service_test.dart` testing Pywal, CSS, JSON, and Hex CSV generation.
- [ ] **Step 2: Run test and verify failure**
  - Run `flutter test test/unit/data/palette_format_service_test.dart`.
- [ ] **Step 3: Implement PaletteFormatService**
  - Create `lib/data/services/palette_format_service.dart` implementing formatting functions with fallback colors.
- [ ] **Step 4: Run test and verify it passes**
  - Run `flutter test test/unit/data/palette_format_service_test.dart`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: implement PaletteFormatService with Pywal, CSS, JSON and Hex exports"`

---

### Task 2: Favorites Storage & Repository Implementation

**Files:**
- Create: `lib/domain/entities/favorite_wallpaper.dart`
- Create: `lib/domain/repositories/i_favorites_repository.dart`
- Create: `lib/data/services/favorites_storage_service.dart`
- Create: `lib/data/repositories/favorites_repository_impl.dart`
- Test: `test/unit/data/favorites_storage_service_test.dart`

**Interfaces:**
- `FavoriteWallpaper` extending `Wallpaper` with `DateTime savedAt`, `String? localFilePath`.
- `IFavoritesRepository`: `loadFavorites()`, `saveFavorite(Wallpaper, {String? localPath})`, `removeFavorite(String id)`, `isFavorite(String id)`.
- `FavoritesStorageService`: Reads and writes `Pictures/WallGem/favorites.json` atomically.

- [ ] **Step 1: Write the failing test**
  - Create `test/unit/data/favorites_storage_service_test.dart` asserting load, save, deduplication, removal, and corrupt JSON recovery using a mock directory.
- [ ] **Step 2: Run test and verify failure**
  - Run `flutter test test/unit/data/favorites_storage_service_test.dart`.
- [ ] **Step 3: Implement Domain entities and Data storage service**
  - Create `lib/domain/entities/favorite_wallpaper.dart`.
  - Create `lib/domain/repositories/i_favorites_repository.dart`.
  - Create `lib/data/services/favorites_storage_service.dart`.
  - Create `lib/data/repositories/favorites_repository_impl.dart`.
- [ ] **Step 4: Run test and verify it passes**
  - Run `flutter test test/unit/data/favorites_storage_service_test.dart`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: implement FavoritesStorageService and IFavoritesRepository with JSON store"`

---

### Task 3: Dynamic Sun Cycle & Auto-Cycler Timer Logic

**Files:**
- Create: `lib/core/utils/day_night_calculator.dart`
- Modify: `lib/presentation/providers/wallpaper_deck_provider.dart`
- Test: `test/unit/core/day_night_calculator_test.dart`
- Test: `test/unit/presentation/auto_cycler_test.dart`

**Interfaces:**
- `DayNightCalculator.isDaytime(DateTime time)` -> bool (true if hour >= 6 and < 20).
- `DayNightCalculator.getRecommendedCategory(DateTime time)` -> String ('Landscape' for day, 'OLED Dark' for night).
- `WallpaperDeckProvider`:
  - `ViewMode viewMode` (`ViewMode.deck`, `ViewMode.vault`), `setViewMode(ViewMode mode)`
  - `bool isDayNightModeEnabled`, `toggleDayNightMode()`
  - `Duration? autoCycleInterval`, `setAutoCycleInterval(Duration? interval)`

- [ ] **Step 1: Write failing tests**
  - Create `test/unit/core/day_night_calculator_test.dart` validating 24h boundaries.
  - Create `test/unit/presentation/auto_cycler_test.dart` validating interval timer behavior and view mode state.
- [ ] **Step 2: Run tests and verify failure**
  - Run tests and confirm failures.
- [ ] **Step 3: Implement DayNightCalculator and update WallpaperDeckProvider**
  - Create `lib/core/utils/day_night_calculator.dart`.
  - Update `lib/presentation/providers/wallpaper_deck_provider.dart` with ViewMode, day/night auto-category switch, and Timer logic.
- [ ] **Step 4: Run tests and verify they pass**
  - Run `flutter test test/unit/core/day_night_calculator_test.dart test/unit/presentation/auto_cycler_test.dart`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: add DayNightCalculator and scheduled interval auto-cycler in WallpaperDeckProvider"`

---

### Task 4: Multi-Monitor Panoramic Splitter Service

**Files:**
- Create: `lib/data/services/multi_monitor_splitter_service.dart`
- Test: `test/unit/data/multi_monitor_splitter_service_test.dart`

**Interfaces:**
- `MultiMonitorSplitterService`:
  - `isPanoramic(String resolution, String ratio)` -> bool (true for 21:9, 32:9 or width/height >= 2.0).
  - `calculateSplitBounds(int width, int height)` -> `({Rect left, Rect right})`.

- [ ] **Step 1: Write the failing test**
  - Create `test/unit/data/multi_monitor_splitter_service_test.dart` testing panoramic detection and geometric bisection.
- [ ] **Step 2: Run test and verify failure**
  - Run `flutter test test/unit/data/multi_monitor_splitter_service_test.dart`.
- [ ] **Step 3: Implement MultiMonitorSplitterService**
  - Create `lib/data/services/multi_monitor_splitter_service.dart`.
- [ ] **Step 4: Run test and verify it passes**
  - Run `flutter test test/unit/data/multi_monitor_splitter_service_test.dart`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: implement MultiMonitorSplitterService with panoramic geometry detection"`

---

### Task 5: FavoritesProvider State Controller

**Files:**
- Create: `lib/presentation/providers/favorites_provider.dart`
- Test: `test/unit/presentation/favorites_provider_test.dart`

**Interfaces:**
- `FavoritesProvider` extending `ChangeNotifier`:
  - `List<FavoriteWallpaper> favorites`
  - `List<FavoriteWallpaper> filteredFavorites`
  - `String searchKeyword`, `setSearchKeyword(String query)`
  - `String selectedCategory`, `setSelectedCategory(String cat)`
  - `Future<void> loadFavorites()`
  - `Future<void> addFavorite(Wallpaper wallpaper, {String? localPath})`
  - `Future<void> removeFavorite(String id)`
  - `bool isFavorite(String id)`

- [ ] **Step 1: Write the failing test**
  - Create `test/unit/presentation/favorites_provider_test.dart` testing loading, search filtering, adding, removing, and listener notifications.
- [ ] **Step 2: Run test and verify failure**
  - Run `flutter test test/unit/presentation/favorites_provider_test.dart`.
- [ ] **Step 3: Implement FavoritesProvider**
  - Create `lib/presentation/providers/favorites_provider.dart`.
- [ ] **Step 4: Run test and verify it passes**
  - Run `flutter test test/unit/presentation/favorites_provider_test.dart`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: implement FavoritesProvider with keyword search and category filtering"`

---

### Task 6: Presentation UI Integration & Widget Testing

**Files:**
- Create: `lib/presentation/widgets/vault/favorites_vault_view.dart`
- Create: `lib/presentation/widgets/vault/favorite_card.dart`
- Create: `lib/presentation/widgets/palette/palette_export_modal.dart`
- Modify: `lib/presentation/widgets/common/header_bar.dart`
- Modify: `lib/presentation/widgets/preview/wallpaper_preview_dialog.dart`
- Modify: `lib/presentation/views/home_screen.dart`
- Modify: `lib/main.dart`
- Test: `test/widget/favorites_vault_view_test.dart`
- Test: `test/widget/home_screen_test.dart`

**UI Deliverables:**
- HeaderBar: Segmented view switcher (`[ 🃏 Deck ] [ 🏛️ Vault (N) ]`), Day/Night toggle (`☀️ / 🌙`), and Auto-cycle timer dropdown (`⏱️ Off, 15m, 30m, 1h, 4h`).
- HomeScreen: Smoothly toggles between `SwipeableCardStack + ActionDock` and `FavoritesVaultView`.
- FavoritesVaultView: Search input, category filter chips, responsive card grid, empty state banner.
- WallpaperPreviewDialog: Color swatches row + "🎨 Export Palette" button opening `PaletteExportModal`.
- MultiProvider in `main.dart` providing `FavoritesProvider`.

- [ ] **Step 1: Write the failing widget tests**
  - Create `test/widget/favorites_vault_view_test.dart` testing grid rendering, search filtering, and action callbacks.
  - Update `test/widget/home_screen_test.dart` verifying view switching without overflow.
- [ ] **Step 2: Run widget tests and verify failure**
  - Run `flutter test test/widget/favorites_vault_view_test.dart`.
- [ ] **Step 3: Implement presentation widgets and wire main.dart**
  - Create `lib/presentation/widgets/palette/palette_export_modal.dart`.
  - Create `lib/presentation/widgets/vault/favorite_card.dart`.
  - Create `lib/presentation/widgets/vault/favorites_vault_view.dart`.
  - Update `lib/presentation/widgets/common/header_bar.dart`.
  - Update `lib/presentation/widgets/preview/wallpaper_preview_dialog.dart`.
  - Update `lib/presentation/views/home_screen.dart`.
  - Update `lib/main.dart` to register `FavoritesProvider`.
- [ ] **Step 4: Run all widget and unit tests**
  - Run `flutter test`.
- [ ] **Step 5: Commit**
  - `git commit -m "feat: integrate Favorites Vault view, Palette modal, and header controls"`

---

### Task 7: Static Analysis, Documentation & Build Verification

**Files:**
- Modify: `README.md`
- Modify: `pubspec.yaml` (bump to 1.2.0)
- Verify: `flutter analyze`
- Verify: `flutter test`
- Build: `flutter build windows --release`

- [ ] **Step 1: Code formatting and static analysis**
  - Run `dart format .`.
  - Run `flutter analyze` (must be 0 issues).
- [ ] **Step 2: Run complete test suite**
  - Run `flutter test` (all tests passing).
- [ ] **Step 3: Update README.md with new features**
  - Document Favorites Vault, Pywal/CSS Palette Export, Day & Night Sun Cycle, and Auto-Cycler Timer.
- [ ] **Step 4: Compile Windows release binary**
  - Run `flutter build windows --release`.
  - Package into `wall-gem-v1.2.0-windows-x64.zip`.
- [ ] **Step 5: Publish release and push to GitHub**
  - Create GitHub release `v1.2.0`.
  - Run `git push origin main`.
