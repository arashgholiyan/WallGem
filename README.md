# Wall Gem 💎

<p align="center">
  <strong>Fast, gesture-driven 4K wallpaper discovery & desktop slideshow engine built with Flutter & Win32 FFI.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart" alt="Dart Version" />
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-0078D6?logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20Provider-6366F1" alt="Architecture" />
  <img src="https://img.shields.io/badge/License-MIT-10B981" alt="License" />
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" />
</p>

---

## ✨ Features

- 🃏 **Tinder-Style Swipe Deck**: Swipe right to like, swipe left to pass, or swipe up to apply immediately as your desktop wallpaper.
- ⚡ **Instant Desktop Application**: Integrates with native Windows Win32 API (`user32.dll` via Dart FFI) to switch wallpapers instantly with safe memory cleanup.
- 🌐 **Multi-Source Aggregation**:
  - **Wallhaven v1 REST API**: Top-rated 4K/UHD wallpapers with genre filters, resolutions, and color palettes.
  - **Bing Daily Wallpaper**: Daily landscape and nature photography archive.
  - **Curated Offline Catalog**: Instant startup without network lag or API rate limits.
- ⌨️ **Desktop-First Keyboard Controls**: Full keyboard accessibility (`←`, `→`, `↑`, `Z`, `Space`, `R`).
- 📁 **Automated Slideshow Batches**: Likes are collected in batches of 5 into `Pictures/WallGem/Slideshow` for automatic Windows desktop background slideshows.
- 🔍 **Full-Screen Inspection Lightbox**: Press `Space` to inspect full-resolution wallpapers before setting them.
- 🛡️ **Zero Overflows & 100% Tested**: Responsive architecture guaranteed to adapt smoothly from small windows up to 4K Ultrawide monitors.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action | Description |
| :---: | :--- | :--- |
| <kbd>→</kbd> | **Like** | Save wallpaper to current batch tray |
| <kbd>←</kbd> | **Pass** | Dismiss current card to history |
| <kbd>↑</kbd> | **Apply Now** | Download and immediately set as desktop wallpaper |
| <kbd>Z</kbd> | **Undo** | Restore the previous card back to the deck |
| <kbd>Space</kbd> | **Inspect** | Open fullscreen high-resolution preview lightbox |
| <kbd>R</kbd> | **Refresh** | Reload initial wallpaper feed |

---

## 🏗️ Architecture

Wall Gem follows **Layered Clean Architecture** powered by `provider`:

```
wall_gem/
├── lib/
│   ├── core/                  # Color tokens, typography, constants, error failures
│   ├── domain/                # Pure entities, repository & platform service contracts
│   │   ├── entities/          # Wallpaper entity
│   │   ├── repositories/      # IWallpaperRepository
│   │   └── services/          # IWallpaperPlatformService
│   ├── data/                  # Data sources, concrete repositories & native FFI
│   │   ├── datasources/       # WallhavenApiSource, BingWallpaperSource, CuratedSource
│   │   ├── models/            # WallpaperModel DTO with JSON & API parsers
│   │   ├── repositories/      # WallpaperRepositoryImpl
│   │   └── services/          # WindowsWallpaperService (user32.dll) & NoopWallpaperService
│   └── presentation/          # State controllers, views, and responsive widgets
│       ├── providers/         # WallpaperDeckProvider, WallpaperActionProvider
│       ├── views/             # HomeScreen
│       └── widgets/           # HeaderBar, ActionDock, SwipeableCardStack, PreviewDialog
└── test/                      # 100% passing unit & widget test suite with hermetic mocking
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.38+ recommended)
- Windows 10/11 with desktop development support enabled (`flutter config --enable-windows-desktop`)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/arashgholiyan/wall-gem.git
   cd wall-gem
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Windows**:
   ```bash
   flutter run -d windows
   ```

4. **Build Release Executable**:
   ```bash
   flutter build windows
   ```
   The compiled `.exe` will be located in `build/windows/x64/runner/Release/`.

---

## 🧪 Testing

Run all unit and widget tests:

```bash
flutter test
```

Verify static analysis:

```bash
flutter analyze --fatal-infos
```

Verify formatting:

```bash
dart format --output=none --set-exit-if-changed .
```

---

## 🤝 Contributing

Contributions are warmly welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on branching, testing, and submitting pull requests.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
