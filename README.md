# Wall Gem 💎

<p align="center">
  <strong>A lightning-fast, gesture-driven 4K wallpaper discovery & desktop slideshow engine for Windows, built with Flutter and native Win32 FFI.</strong>
</p>

<p align="center">
  <a href="https://github.com/arashgholiyan/wall-gem/releases/latest">
    <img src="https://img.shields.io/github/v/release/arashgholiyan/wall-gem?color=6366F1&label=Latest%20Release&logo=github" alt="Latest Release" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-0078D6?logo=windows" alt="Platform Windows" />
  <img src="https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart" alt="Dart Version" />
  <img src="https://img.shields.io/badge/License-MIT-10B981" alt="License MIT" />
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" />
</p>

<p align="center">
  <a href="https://github.com/arashgholiyan/wall-gem/releases/latest">
    <img src="https://img.shields.io/badge/📥_Download_for_Windows-v1.0.0_Portable_ZIP-success?style=for-the-badge&logo=windows" alt="Download Windows Release" />
  </a>
</p>

---

## 📸 App Interface Preview

<p align="center">
  <img src="docs/assets/ui_preview.svg" alt="Wall Gem App UI Preview" width="100%" />
</p>

---

## 🎬 How It Works

Wall Gem transforms finding desktop wallpapers from browsing messy websites into an addictive, frictionless swipe deck.

<p align="center">
  <img src="docs/assets/workflow.svg" alt="Wall Gem Workflow" width="100%" />
</p>

### 1. Multi-Source UHD Feed Aggregation
Wall Gem simultaneously queries official high-resolution APIs without web scraping or CAPTCHAs:
- **Wallhaven v1 REST API**: Top-rated 4K & 8K community wallpapers filtered by SFW purity, genres, and color palettes.
- **Bing Daily Wallpaper Archive**: High-definition national geography and landscape photography.
- **Curated High-Res Library**: Built-in offline fallback that guarantees instant startup with zero loading stutters.

### 2. Gesture-Driven Swipe Deck
Just like Tinder, browse through an infinite stack of wallpapers using fluid mouse gestures or desktop keyboard shortcuts:
- **Swipe Right** (<kbd>→</kbd>): **Like** the wallpaper and add it to your current batch tray.
- **Swipe Left** (<kbd>←</kbd>): **Pass** and dismiss the card.
- **Swipe Up** (<kbd>↑</kbd>): **Apply Now** — downloads the UHD image and sets it directly as your Windows desktop wallpaper in under a second!
- **Undo** (<kbd>Z</kbd>): Made a mistake? Step backward and bring the previous wallpaper back to the top of the stack.
- **Inspect** (<kbd>Space</kbd>): Opens the full-screen high-resolution preview lightbox to examine image clarity, dimensions, and photographer credits.

### 3. Native Windows Desktop Integration (Win32 FFI)
No third-party daemon or background bloatware required. Wall Gem connects directly to the Windows OS kernel via `user32.dll` (`SystemParametersInfoW`) using Dart FFI, applying desktop wallpapers instantly with safe memory cleanup.

### 4. Automated 5-Wallpaper Slideshow Batches
Whenever you like **5 wallpapers**, Wall Gem automatically synchronizes them into your local Windows slideshow directory:
```
C:\Users\<YourUsername>\Pictures\WallGem\Slideshow
```
You can configure Windows Desktop Personalization to point to this directory for a custom rotating slideshow of all your saved gems.

---

## ⌨️ Desktop Keyboard Controls

| Key | Action | Function |
| :---: | :--- | :--- |
| <kbd>→</kbd> | **Like** | Save wallpaper to current batch tray |
| <kbd>←</kbd> | **Pass** | Dismiss current card to history |
| <kbd>↑</kbd> | **Apply Now** | Download & set as current Windows wallpaper immediately |
| <kbd>Z</kbd> | **Undo** | Restore the previously swiped card |
| <kbd>Space</kbd> | **Inspect Lightbox** | Open fullscreen high-res viewer |
| <kbd>R</kbd> | **Refresh** | Reload fresh feed from APIs |

---

## 🚀 Download & Installation

### For End Users (No Developer Tools Required)

1. Go to the **[Latest Release](https://github.com/arashgholiyan/wall-gem/releases/latest)** page.
2. Download **`wall-gem-windows-x64.zip`** (Portable).
3. Extract the `.zip` archive to any folder (e.g. `Downloads` or `Desktop`).
4. Double-click **`wall_gem.exe`** to start discovering wallpapers!

---

### For Developers & Contributors

1. **Clone the repository**:
   ```bash
   git clone https://github.com/arashgholiyan/wall-gem.git
   cd wall-gem
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Windows Desktop**:
   ```bash
   flutter run -d windows
   ```

4. **Run Test Suite**:
   ```bash
   flutter test
   ```

---

## 🏗️ Architecture Overview

Wall Gem follows **Layered Clean Architecture** powered by `provider`:

```
wall_gem/
├── .github/
│   ├── workflows/
│   │   ├── flutter_ci.yml     # Automated linting & unit tests
│   │   └── release.yml        # Automated cloud builds & GitHub releases
│   ├── ISSUE_TEMPLATE/        # Bug report & feature request templates
│   └── PULL_REQUEST_TEMPLATE  # Standardized PR checklist
├── lib/
│   ├── core/                  # Color tokens, constants, theme, failure types
│   ├── domain/                # Entities, repository & platform service interfaces
│   │   ├── entities/          # Wallpaper entity
│   │   ├── repositories/      # IWallpaperRepository
│   │   └── services/          # IWallpaperPlatformService
│   ├── data/                  # API data sources, models, and native Win32 FFI
│   │   ├── datasources/       # WallhavenApiSource, BingWallpaperSource, CuratedSource
│   │   ├── models/            # WallpaperModel DTO with JSON serialization
│   │   ├── repositories/      # WallpaperRepositoryImpl
│   │   └── services/          # WindowsWallpaperService (user32.dll) & NoopWallpaperService
│   └── presentation/          # State controllers, views, and responsive widgets
│       ├── providers/         # WallpaperDeckProvider, WallpaperActionProvider
│       ├── views/             # HomeScreen
│       └── widgets/           # HeaderBar, ActionDock, SwipeableCardStack, Lightbox
└── test/                      # Hermetic unit & widget test suite (100% passing)
```

---

## 📦 Automated Release Pipeline

Releases are built in the cloud via GitHub Actions:
- Pushing a new tag (e.g. `git tag v1.0.1 && git push origin v1.0.1`) triggers `.github/workflows/release.yml`.
- A Windows cloud runner compiles `flutter build windows --release`.
- GitHub creates a new Release entry and uploads the portable `.zip` and `.msix` bundles automatically.

---

## 🤝 Contributing

Contributions are welcome! Check out [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
