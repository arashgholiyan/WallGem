# Architecture & Design Specification: Wall Gem Rebuild

- **Project**: Wall Gem (Desktop Wallpaper Curation & Slideshow Engine)
- **Author**: Antigravity & User
- **Date**: 2026-10-13
- **Status**: Approved

---

## 1. Executive Summary

**Wall Gem** is a desktop Flutter application featuring a fast, gesture-driven and keyboard-accessible card-swiping interface for discovering, previewing, and applying high-resolution (4K/UHD) wallpapers to the Windows desktop.

This specification details a complete rebuild of the codebase from a monolithic 1340-line prototype (`wallpaper_swiper_app`) into a clean, modular, extensible, and fully tested open-source project (`wall_gem`) that is ready for GitHub publication.

---

## 2. Problems Addressed

1. **Monolithic Codebase**: The entire app logic, UI, scrapers, state, and native Win32 FFI resided in `lib/main.dart` (~1342 lines).
2. **Brittle Data Sources**: The original app relied on fragile regular expression scraping against third-party HTML pages and hardcoded placeholder links.
3. **Layout Overflow Bug**: The header row triggered an immediate layout error (`RenderFlex overflowed by 78 pixels on the right`), failing automated widget tests.
4. **Untestable Architecture**: Direct network requests and Win32 FFI calls in widget trees prevented mockable unit and widget testing.
5. **Lack of Open-Source Standards**: Missing Git repository, GitHub Actions CI workflow, issue/PR templates, MIT license, contribution guides, and architectural documentation.

---

## 3. System Architecture

The application adopts a **Layered Clean Architecture** decoupled into four primary layers:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   Views (HomeScreen), Widgets (Deck, Cards, Docks),    │
│   State Providers (WallpaperDeckProvider, ActionProv)  │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   Entities (Wallpaper), Repository & Service Contracts │
│   (IWallpaperRepository, IWallpaperPlatformService)    │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────┐
│                       Data Layer                       │
│   Data Sources (WallhavenApi, BingDaily, Curated),     │
│   Repository Impl (WallpaperRepositoryImpl),           │
│   Platform Services (WindowsWallpaperService via FFI)   │
└────────────────────────────────────────────────────────┘
```

### 3.1 Layer Responsibilities

- **Domain Layer (`lib/domain/`)**:
  - `Wallpaper`: Immutable core entity containing identity, URLs, dimensions, aspect ratio, categories, and color palettes.
  - `IWallpaperRepository`: Contract defining `fetchWallpapers({required String category, int page})` and `searchWallpapers(String query)`.
  - `IWallpaperPlatformService`: Contract defining `setWallpaper(String filePath)`, `downloadWallpaper(String url, String destinationPath)`, and `defaultWallpaperDirectory`.

- **Data Layer (`lib/data/`)**:
  - `WallpaperModel`: JSON-serializable DTO mapping Wallhaven v1 responses and Bing daily wallpaper schemas to domain entities.
  - `WallhavenApiSource`: Interacts with `https://wallhaven.cc/api/v1/search` using official query parameters (`q`, `categories`, `purity`, `sorting`, `atleast`).
  - `BingWallpaperSource`: Interacts with `https://www.bing.com/HPImageArchive.aspx` for daily high-resolution photography.
  - `CuratedWallpaperSource`: Built-in catalog providing instant offline readiness and graceful degradation during network unavailability.
  - `WallpaperRepositoryImpl`: Aggregates, deduplicates, caches, and shuffles wallpaper feeds across available sources.
  - `WindowsWallpaperService`: Implements `IWallpaperPlatformService` using Win32 `user32.dll` (`SystemParametersInfoW`) via Dart FFI with strict memory reclamation (`calloc.free`).
  - `NoopWallpaperService`: Safe fallback implementation for non-Windows platforms and unit/widget test environments.

- **Presentation Layer (`lib/presentation/`)**:
  - `WallpaperDeckProvider`: Manages card stack state, directional gestures, undo history, automatic prefetching, and batch completion tracking.
  - `WallpaperActionProvider`: Coordinates file downloads, wallpaper application, and Windows Explorer folder launching.
  - `HomeScreen`: Root responsive scaffold supporting multiple screen dimensions without overflow.
  - `SwipeableCardStack`: Draggable card deck with physics-based swipe thresholds, dynamic stamps, and layered 3D depth cards.
  - `ActionDock`: Accessible control buttons (Pass, Like, Apply Now, Inspect Preview, Undo).
  - `WallpaperPreviewDialog`: Fullscreen image viewer with detailed metadata.

- **Core Layer (`lib/core/`)**:
  - `AppConstants`: Global categories, API endpoints, timeout thresholds, and local storage paths.
  - `AppColors`: Palette tokens (Deep Obsidian `0xFF06070A`, Neon Indigo `0xFF6366F1`, Emerald `0xFF10B981`, Rose `0xFFF43F5E`, Amber `0xFFF59E0B`).
  - `AppTheme`: Dark Material 3 theme incorporating Google Fonts Plus Jakarta Sans.
  - `Failures`: Typed error classes (`NetworkFailure`, `PlatformFailure`, `ParseFailure`).

---

## 4. Key Workflows & Interactions

### 4.1 Card Swiping & Actions
- **Swipe Right (`→`)**: Wallpapers are liked and added to the current batch tray. If 5 items are collected, `BatchCompleteDialog` opens with options to inspect files in Windows Explorer.
- **Swipe Left (`←`)**: Wallpapers are passed and archived into undo history.
- **Swipe Up / Star Button (`↑`)**: Wallpapers are liked AND immediately downloaded and set as the current Windows desktop wallpaper via `WindowsWallpaperService`.
- **Undo (`Z`)**: Restores the previously swiped wallpaper back to the top of the deck.
- **Inspect (`Space`)**: Launches `WallpaperPreviewDialog` displaying full-resolution image and source metadata.

### 4.2 Safe Native FFI Implementation
- Dynamic library loading: `DynamicLibrary.open('user32.dll')`.
- Function lookup: `SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, pathPointer, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE)`.
- Allocated pointer cleanup is guaranteed inside `finally` blocks:
  ```dart
  final pathPointer = filePath.toNativeUtf16();
  try {
    systemParametersInfoW(20, 0, pathPointer, 0x01 | 0x02);
  } finally {
    calloc.free(pathPointer);
  }
  ```

---

## 5. Responsive UI & Overflow Resolution

The header row layout is restructured to guarantee overflow immunity:
1. Replaced rigid `Row` with responsive constraints and `Expanded`/`Flexible` children.
2. Badge and progress widgets scale dynamically or hide secondary labels when horizontal viewport width is under 600px.
3. Card deck dynamically calculates sizing: `width: min(880, screenWidth * 0.9)`, `height: min(540, screenHeight * 0.62)`.

---

## 6. Testing Strategy

1. **Hermetic Network Testing**: `MockHttpClient` handles HTTP requests in unit and widget tests without connecting to the internet.
2. **Unit Tests**:
   - `wallpaper_model_test.dart`: Serialization, deserialization, and edge-case handling.
   - `wallhaven_api_source_test.dart`: Parameter construction and response JSON transformation.
   - `wallpaper_deck_provider_test.dart`: Deck operations, history stack, batch counting, and undo operations.
3. **Widget Tests**:
   - `home_screen_test.dart`: Tests across viewport resolutions (800x600, 1200x800, 1920x1080), verifying zero `RenderFlex` assertions and proper widget mounting.
   - `action_dock_test.dart`: Verifies button taps and keyboard interaction triggers.

---

## 7. GitHub Open-Source Assets

1. **Repository Renaming**: Package name updated to `wall_gem`.
2. **GitHub Actions Workflow (`.github/workflows/flutter_ci.yml`)**:
   - Environment: Ubuntu / Windows matrix or standard stable Flutter runner.
   - Pipeline: `flutter pub get` → `dart format --output=none --set-exit-if-changed .` → `flutter analyze --fatal-infos` → `flutter test`.
3. **Community Templates**:
   - `.github/ISSUE_TEMPLATE/bug_report.md`
   - `.github/ISSUE_TEMPLATE/feature_request.md`
   - `.github/PULL_REQUEST_TEMPLATE.md`
4. **Documentation**:
   - `README.md`: Badges, hero graphic, architectural overview, shortcut chart, build commands, and contribution roadmap.
   - `CONTRIBUTING.md`: Coding standards, branching strategies, and PR guidelines.
   - `LICENSE`: MIT License.
   - `.gitignore`: Complete Flutter and platform build exclusions.
5. **Git Repository Setup**: Local repository initialized with a clean initial commit.
