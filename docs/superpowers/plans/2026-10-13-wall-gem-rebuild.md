# Wall Gem Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Completely rebuild Wall Gem into a modular, clean-architecture Flutter desktop app with official wallpaper sources, safe Win32 FFI, responsive overflow-free UI, 100% passing tests, and full open-source GitHub readiness.

**Architecture:** Layered Clean Architecture using Dart domain entities and interfaces, concrete REST/curated data sources, safe native Windows FFI wallpaper service, and Provider-based reactive presentation controllers.

**Tech Stack:** Flutter 3.38+ / Dart 3.10+, Provider, CachedNetworkImage, GoogleFonts, Dart FFI (user32.dll), Http, Flutter Test.

**Spec:** `docs/superpowers/specs/2026-10-13-wall-gem-rebuild-design.md`

## Global Constraints

- Package name in `pubspec.yaml`: `wall_gem`.
- SDK constraints: `sdk: ^3.10.8`, Flutter stable channel.
- Zero `RenderFlex` overflows at any viewport width (>= 600px).
- Zero uncaught network leaks during testing (hermetic mock HTTP client).
- Memory-safe FFI (all pointers freed via `calloc.free` in `finally` blocks).
- 100% passing unit and widget test suite with zero analyze warnings.

## Review Focus

1. *Network outage during feed fetch*: Must fallback seamlessly to cached/curated wallpapers without crashing or blank screen.
2. *Non-Windows operating system execution*: Native FFI service must gracefully bypass Win32 calls without crashing.
3. *Rapid card swiping / keyboard spamming*: Gesture state must prevent concurrent double-swipe race conditions on the deck stack.
4. *Window resize below 800px*: Header bar must adaptively compress elements rather than overflowing `RenderFlex`.
5. *HTTP 429 Rate Limiting from Wallhaven API*: Must handle rate limiting smoothly and surface friendly status without application crash.

---

### Task 1: Package Reconfiguration, Core Constants & Theme

**Files:**
- Modify: `pubspec.yaml`
- Modify: `analysis_options.yaml`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/core/constants/app_keys.dart`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/errors/failure.dart`
- Test: `test/unit/core/app_constants_test.dart`

**Interfaces:**
- Produces: `AppConstants`, `AppKeys`, `AppColors`, `AppTheme.darkTheme`, `Failure` hierarchies (`NetworkFailure`, `PlatformFailure`).

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/core/app_constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/core/constants/app_constants.dart';
import 'package:wall_gem/core/errors/failure.dart';

void main() {
  test('AppConstants contains expected categories and paths', () {
    expect(AppConstants.appName, equals('Wall Gem'));
    expect(AppConstants.categories, contains('All'));
    expect(AppConstants.categories, contains('Landscape'));
    expect(AppConstants.batchTarget, equals(5));
  });

  test('Failure classes preserve messages', () {
    const failure = NetworkFailure('Connection refused');
    expect(failure.message, equals('Connection refused'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/core/app_constants_test.dart`
Expected: FAIL (files and package `wall_gem` do not exist yet)

- [ ] **Step 3: Update `pubspec.yaml` and implement core modules**

1. Update `name: wall_gem` in `pubspec.yaml`, add `provider: ^6.1.2`.
2. Run `flutter pub get`.
3. Implement `lib/core/constants/app_constants.dart`, `lib/core/constants/app_keys.dart`, `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `lib/core/errors/failure.dart`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/core/app_constants_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml lib/core test/unit/core
git commit -m "feat(core): configure wall_gem package, theme, and constants"
```

---

### Task 2: Domain Layer Entities & Data Models

**Files:**
- Create: `lib/domain/entities/wallpaper.dart`
- Create: `lib/domain/repositories/i_wallpaper_repository.dart`
- Create: `lib/domain/services/i_wallpaper_service.dart`
- Create: `lib/data/models/wallpaper_model.dart`
- Test: `test/unit/data/wallpaper_model_test.dart`

**Interfaces:**
- Consumes: `AppConstants` from Task 1.
- Produces: `Wallpaper` entity, `WallpaperModel`, `IWallpaperRepository`, `IWallpaperPlatformService`.

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/data/wallpaper_model_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/models/wallpaper_model.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';

void main() {
  test('WallpaperModel serializes to and from JSON', () {
    final model = WallpaperModel(
      id: 'test_1',
      title: 'Neon Cyberpunk',
      author: 'CyberArtist',
      sourceName: 'wallhaven.cc',
      thumbUrl: 'https://example.com/thumb.jpg',
      fullUrl: 'https://example.com/full.jpg',
      resolution: '3840x2160',
      ratio: '16:9',
      category: 'Cyberpunk',
      colors: const [Color(0xFF6366F1)],
    );

    final json = model.toJson();
    final reconstructed = WallpaperModel.fromJson(json);

    expect(reconstructed.id, equals(model.id));
    expect(reconstructed.title, equals(model.title));
    expect(reconstructed.toEntity(), isA<Wallpaper>());
  });

  test('WallpaperModel parses Wallhaven API item', () {
    final wallhavenItemJson = {
      'id': '9m9yvd',
      'path': 'https://w.wallhaven.cc/full/9m/wallhaven-9m9yvd.jpg',
      'thumbs': {
        'small': 'https://th.wallhaven.cc/small/9m/9m9yvd.jpg',
        'large': 'https://th.wallhaven.cc/lg/9m/9m9yvd.jpg',
      },
      'resolution': '3840x2160',
      'ratio': '1.78',
      'category': 'anime',
      'colors': ['#663399'],
      'uploader': {'username': 'Artist'},
    };

    final model = WallpaperModel.fromWallhavenJson(wallhavenItemJson);
    expect(model.id, equals('wallhaven_9m9yvd'));
    expect(model.sourceName, equals('wallhaven.cc'));
    expect(model.colors.isNotEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/data/wallpaper_model_test.dart`
Expected: FAIL (files do not exist)

- [ ] **Step 3: Implement domain entities, service interfaces, and `WallpaperModel`**

Create `lib/domain/entities/wallpaper.dart`, `lib/domain/repositories/i_wallpaper_repository.dart`, `lib/domain/services/i_wallpaper_service.dart`, `lib/data/models/wallpaper_model.dart`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/data/wallpaper_model_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain lib/data/models test/unit/data/wallpaper_model_test.dart
git commit -m "feat(domain): add wallpaper entity, repository interfaces and model"
```

---

### Task 3: Remote Data Sources & Repository Implementation

**Files:**
- Create: `test/mocks/mock_http_client.dart`
- Create: `lib/data/datasources/wallhaven_api_source.dart`
- Create: `lib/data/datasources/bing_wallpaper_source.dart`
- Create: `lib/data/datasources/curated_wallpaper_source.dart`
- Create: `lib/data/repositories/wallpaper_repository_impl.dart`
- Test: `test/unit/data/wallhaven_api_source_test.dart`
- Test: `test/unit/data/wallpaper_repository_test.dart`

**Interfaces:**
- Consumes: `WallpaperModel`, `Wallpaper`, `IWallpaperRepository` from Task 2.
- Produces: `WallhavenApiSource`, `BingWallpaperSource`, `CuratedWallpaperSource`, `WallpaperRepositoryImpl`.

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/data/wallhaven_api_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/datasources/wallhaven_api_source.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  test('WallhavenApiSource returns parsed wallpaper models on HTTP 200', () async {
    final mockClient = createMockHttpClient(
      responseBody: '{"data":[{"id":"1","path":"https://full.jpg","thumbs":{"large":"https://thumb.jpg"},"resolution":"3840x2160","ratio":"16:9","category":"general","colors":["#ffffff"]}]}',
      statusCode: 200,
    );

    final source = WallhavenApiSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);

    expect(items.length, equals(1));
    expect(items.first.id, equals('wallhaven_1'));
  });

  test('WallhavenApiSource returns empty list on network error gracefully', () async {
    final mockClient = createMockHttpClient(responseBody: '', statusCode: 500);
    final source = WallhavenApiSource(client: mockClient);
    final items = await source.fetchWallpapers(category: 'All', page: 1);
    expect(items, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/data/wallhaven_api_source_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `MockHttpClient`, API sources, and `WallpaperRepositoryImpl`**

1. Create `test/mocks/mock_http_client.dart`.
2. Implement `WallhavenApiSource` (official query schema), `BingWallpaperSource` (HPImageArchive.aspx parser), `CuratedWallpaperSource` (curated offline items), and `WallpaperRepositoryImpl`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/data/wallhaven_api_source_test.dart test/unit/data/wallpaper_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/mocks lib/data/datasources lib/data/repositories test/unit/data
git commit -m "feat(data): add wallpaper data sources and repository implementation"
```

---

### Task 4: Native Windows FFI & Platform Service

**Files:**
- Create: `lib/data/services/windows_wallpaper_service.dart`
- Create: `lib/data/services/noop_wallpaper_service.dart`
- Test: `test/unit/data/wallpaper_service_test.dart`

**Interfaces:**
- Consumes: `IWallpaperPlatformService` from Task 2.
- Produces: `WindowsWallpaperService`, `NoopWallpaperService`.

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/data/wallpaper_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/services/i_wallpaper_service.dart';

void main() {
  test('NoopWallpaperService provides safe path and succeeds safely', () async {
    final IWallpaperPlatformService service = NoopWallpaperService();
    expect(service.defaultSlideshowDirectory, contains('WallGem'));
    final success = await service.setWallpaper('dummy/path.jpg');
    expect(success, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/data/wallpaper_service_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `WindowsWallpaperService` and `NoopWallpaperService`**

1. Implement `WindowsWallpaperService` using `user32.dll` `SystemParametersInfoW` with `try / finally { calloc.free(pathPointer); }`.
2. Implement `NoopWallpaperService`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/data/wallpaper_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/services test/unit/data/wallpaper_service_test.dart
git commit -m "feat(platform): implement safe Win32 FFI and fallback wallpaper services"
```

---

### Task 5: Presentation Providers (State Management)

**Files:**
- Create: `lib/presentation/providers/wallpaper_deck_provider.dart`
- Create: `lib/presentation/providers/wallpaper_action_provider.dart`
- Test: `test/unit/presentation/wallpaper_deck_provider_test.dart`

**Interfaces:**
- Consumes: `Wallpaper`, `IWallpaperRepository`, `IWallpaperPlatformService`.
- Produces: `WallpaperDeckProvider`, `WallpaperActionProvider`.

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/presentation/wallpaper_deck_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';

class FakeWallpaperRepository implements IWallpaperRepository {
  @override
  Future<List<Wallpaper>> fetchWallpapers({required String category, int page = 1}) async {
    return List.generate(
      10,
      (i) => Wallpaper(
        id: 'wall_$i',
        title: 'Wallpaper $i',
        author: 'Artist',
        sourceName: 'Source',
        thumbUrl: 'https://thumb.jpg',
        fullUrl: 'https://full.jpg',
        resolution: '4K',
        aspectRatio: '16:9',
        category: 'All',
        dominantColors: const [],
      ),
    );
  }
}

void main() {
  test('WallpaperDeckProvider manages deck, swipe right, undo, and batch threshold', () async {
    final repo = FakeWallpaperRepository();
    final provider = WallpaperDeckProvider(repository: repo);

    await provider.loadInitialFeed();
    expect(provider.deck.length, equals(10));

    final firstItem = provider.deck.first;
    provider.swipeRight(); // Like

    expect(provider.deck.length, equals(9));
    expect(provider.likedList.length, equals(1));
    expect(provider.likedList.first.id, equals(firstItem.id));

    // Undo
    provider.undo();
    expect(provider.deck.length, equals(10));
    expect(provider.likedList, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/presentation/wallpaper_deck_provider_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `WallpaperDeckProvider` and `WallpaperActionProvider`**

1. Create `WallpaperDeckProvider` with deck, undo stack, batch tracking, prefetch triggers, and auto-refill logic.
2. Create `WallpaperActionProvider` with download and wallpaper application workflows.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/presentation/wallpaper_deck_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/providers test/unit/presentation
git commit -m "feat(presentation): implement deck and action providers"
```

---

### Task 6: Rebuilt Presentation Widgets, Responsive Shell & Main Wiring

**Files:**
- Create: `lib/presentation/widgets/common/header_bar.dart`
- Create: `lib/presentation/widgets/common/category_selector.dart`
- Create: `lib/presentation/widgets/common/action_dock.dart`
- Create: `lib/presentation/widgets/deck/card_badge.dart`
- Create: `lib/presentation/widgets/deck/wallpaper_card.dart`
- Create: `lib/presentation/widgets/deck/swipeable_card_stack.dart`
- Create: `lib/presentation/widgets/preview/wallpaper_preview_dialog.dart`
- Create: `lib/presentation/widgets/batch/batch_complete_dialog.dart`
- Create: `lib/presentation/widgets/thumbnail_tray.dart`
- Create: `lib/presentation/views/home_screen.dart`
- Modify: `lib/main.dart`
- Create: `test/widget/home_screen_test.dart`
- Create: `test/widget/action_dock_test.dart`

**Interfaces:**
- Consumes: All core, domain, data, and presentation providers.
- Produces: Complete Wall Gem application UI.

- [ ] **Step 1: Write the failing widget tests**

```dart
// test/widget/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wall_gem/data/services/noop_wallpaper_service.dart';
import 'package:wall_gem/domain/entities/wallpaper.dart';
import 'package:wall_gem/domain/repositories/i_wallpaper_repository.dart';
import 'package:wall_gem/presentation/providers/wallpaper_action_provider.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';
import 'package:wall_gem/presentation/views/home_screen.dart';

class StubRepository implements IWallpaperRepository {
  @override
  Future<List<Wallpaper>> fetchWallpapers({required String category, int page = 1}) async {
    return [
      const Wallpaper(
        id: '1',
        title: 'Cyber View',
        author: 'Artist',
        sourceName: 'wallhaven.cc',
        thumbUrl: 'https://example.com/thumb.jpg',
        fullUrl: 'https://example.com/full.jpg',
        resolution: '3840x2160',
        aspectRatio: '16:9',
        category: 'Cyberpunk',
        dominantColors: [Colors.purple],
      )
    ];
  }
}

void main() {
  testWidgets('HomeScreen renders without any RenderFlex overflow on standard screen', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = StubRepository();
    final deckProvider = WallpaperDeckProvider(repository: repo);
    final actionProvider = WallpaperActionProvider(service: NoopWallpaperService());
    await deckProvider.loadInitialFeed();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: deckProvider),
          ChangeNotifierProvider.value(value: actionProvider),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wall Gem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/home_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement modular widgets, HomeScreen, and main.dart**

1. Build `HeaderBar` with responsive `LayoutBuilder` / `Flexible` preventing any overflow.
2. Build `CategorySelector`, `ActionDock`, `WallpaperCard`, `SwipeableCardStack`, `WallpaperPreviewDialog`, `BatchCompleteDialog`, `ThumbnailTray`.
3. Build `HomeScreen` with desktop keyboard listener (`←`, `→`, `↑`, `Z`, `Space`).
4. Wire `lib/main.dart` with `MultiProvider` injecting real platform services and repositories.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widget/`
Expected: ALL PASS with 0 exceptions

- [ ] **Step 5: Commit**

```bash
git add lib/presentation lib/main.dart test/widget
git commit -m "feat(ui): rebuild responsive swipe deck, header, and dialogs with zero overflow"
```

---

### Task 7: GitHub Open-Source Assets & Repository Scaffolding

**Files:**
- Create: `.github/workflows/flutter_ci.yml`
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/feature_request.md`
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `LICENSE` (MIT)
- Create: `CONTRIBUTING.md`
- Modify: `README.md`
- Modify: `.gitignore`

**Interfaces:**
- Produces: Complete GitHub-ready repository scaffolding.

- [ ] **Step 1: Create GitHub Actions workflow file**

Write `.github/workflows/flutter_ci.yml` with formatting, analyze, and test jobs on GitHub runners.

- [ ] **Step 2: Create community issue and PR templates**

Write bug report, feature request templates, and PR template.

- [ ] **Step 3: Create LICENSE, CONTRIBUTING.md, and comprehensive README.md**

Write MIT License, contribution guide, and a modern `README.md` containing badges, architecture overview, feature list, keyboard shortcuts guide, and build/run instructions.

- [ ] **Step 4: Initialize Git repository and commit**

Initialize git repository in `Wall Gem`, add all files, and verify `git status`.

- [ ] **Step 5: Commit**

```bash
git init
git add .
git commit -m "chore: scaffold GitHub workflows, documentation, and open-source assets"
```

---

### Task 8: End-to-End Verification

**Files:**
- Entire codebase

- [ ] **Step 1: Run code formatter**

Run: `dart format --output=none --set-exit-if-changed lib test`
Expected: 0 changes needed or formatted cleanly.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Run complete test suite**

Run: `flutter test`
Expected: 100% tests passing with 0 failures and 0 warnings.

- [ ] **Step 4: Final commit and verify git log**

Verify `git log --oneline`.
