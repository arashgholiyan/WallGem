# Wall Gem 💎

<p align="center">
  <strong>A lightning-fast, gesture-driven 4K wallpaper discovery engine & desktop personalization suite for Windows.</strong>
  <br />
  <em>Engineered with Flutter, Clean Architecture, and native Win32 FFI kernel hooks.</em>
</p>

<p align="center">
  <a href="https://github.com/arashgholiyan/wall-gem/releases/latest">
    <img src="https://img.shields.io/github/v/release/arashgholiyan/wall-gem?color=6366F1&label=Release&logo=github" alt="Release" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/Tests-35%2F35%20Passing-10B981?logo=checkmarx" alt="Tests" />
  <img src="https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/License-MIT-purple" alt="License" />
</p>

<p align="center">
  <a href="https://github.com/arashgholiyan/wall-gem/releases/latest">
    <img src="https://img.shields.io/badge/📥_Download_Executable-v1.1.0_x64_Portable-success?style=for-the-badge&logo=windows" alt="Download Windows Release" />
  </a>
</p>

---

## 🎨 Overview

Finding exceptional desktop wallpapers shouldn't mean sifting through slow, ad-ridden web galleries or waiting on arbitrary download countdowns. 

**Wall Gem** reimagines wallpaper discovery into an instant, tactile **60 FPS swipe deck**. Built from the ground up for desktop ergonomics, it concurrently streams ultra-high-definition wallpapers from **10 distinct platforms**, deduplicates them in real time, and connects directly to the Windows OS kernel to apply changes in milliseconds—with **zero API keys**, **zero background bloatware**, and **zero telemetry**.

<p align="center">
  <img src="docs/assets/ui_preview.svg" alt="Wall Gem Interface Preview" width="100%" />
</p>

---

## ✨ Engineering Highlights

- **⚡ Native Win32 Kernel FFI (`user32.dll`)**  
  Bypasses heavy background daemons and external scripts. Directly invokes `SystemParametersInfoW` via Dart FFI with UTF-16 pointer allocation and immediate memory cleanup, switching desktop backgrounds in under 100ms.
- **🌐 10-Platform Concurrent Pipeline**  
  Queries 10 high-resolution providers simultaneously with asynchronous pooling, real-time URL deduplication, and resilient fallback handling.
- **🃏 Tactile 60 FPS Card Physics**  
  Fluid swipe mechanics built with hardware-accelerated animations, spring curves, full keyboard hotkey support, and an undo history stack.
- **🖼️ Automated Windows Slideshow Sync**  
  Every 5 liked wallpapers are automatically synchronized into `Pictures\WallGem\Slideshow`, seamlessly integrating with native Windows desktop rotation.
- **🛡️ Strict Clean Architecture & 100% Hermetic Tests**  
  Decoupled Presentation, Domain, and Data layers. Every remote provider, parser, and state controller is covered by an automated test harness (35 passing unit & widget tests, 0 analyzer warnings).

---

## 🔄 Interaction Workflow

<p align="center">
  <img src="docs/assets/workflow.svg" alt="Wall Gem Architectural Workflow" width="100%" />
</p>

---

## 🌐 Pluggable Multi-Source Engine

Wall Gem is built with a modular, pluggable provider architecture. The engine concurrently streams, deduplicates, and aggregates ultra-high-definition wallpapers across diverse aesthetic categories without requiring accounts or personal API keys:

| Category | Typical Resolutions | Visual Focus | Ingestion Engine |
| :--- | :---: | :--- | :--- |
| **Landscapes & Nature** | 4K UHD (3840×2160) | Mountain vistas, national parks, coastal ridges | Open REST & CDN Feeds |
| **AMOLED & Minimal** | 4K UHD / True Black | High-contrast dark modes, clean geometry, vector art | Public Metadata Indexer |
| **Gaming & Sci-Fi** | 4K / 8K UHD | Cyberpunk megacities, concept art, futuristic themes | Structured Schema Stream |
| **Studio Photography** | 5K Studio (5000×3333) | Fine-art textures, architectural photography | CC0 / Public Domain CDN |
| **Vehicles & Speed** | 4K UHD (3840×2160) | Supercars, aviation, modern industrial engineering | Public Open Endpoints |
| **Digital & Anime** | 4K UHD (3840×2160) | Expressive illustrations, anime skies, 3D renders | Community Public APIs |
| **Daily Curated** | 4K UHD | Fresh daily rotating landscape & geography photography | Daily Rolling Archives |

*The modular provider interface (`IWallpaperRepository`) makes it trivial for developers to plug in custom local directories, self-hosted servers, or additional open web endpoints.*

---

## ⌨️ Desktop Shortcuts

Engineered for power users and keyboard ergonomics:

| Key | Action | Behavior |
| :---: | :--- | :--- |
| <kbd>→</kbd> | **Like** | Push wallpaper to current batch tray |
| <kbd>←</kbd> | **Pass** | Dismiss current card to history |
| <kbd>↑</kbd> | **Apply Now** | Download & set as desktop background instantly via Win32 FFI |
| <kbd>Z</kbd> | **Undo** | Pop and restore the previously dismissed card |
| <kbd>Space</kbd> | **Inspect Lightbox** | Open fullscreen high-res zoom & metadata inspection |
| <kbd>R</kbd> | **Refresh** | Trigger fresh network fetch from active platform |

---

## 🏗️ Architecture & Clean Design

Wall Gem adopts Uncle Bob's **Clean Architecture** with unidirectional data flow:

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│    HomeScreen  •  SwipeableCardStack  •  ActionDock  •  Header    │
│            State: WallpaperDeckProvider, ActionProvider            │
└──────────────────────────────┬──────────────────────────────┘
                               │ (calls use cases / repos)
┌──────────────────────────────▼──────────────────────────────┐
│                         DOMAIN LAYER                        │
│   Entities: WallpaperEntity  •  Interfaces: IWallpaperRepository  │
│                Service Contract: IWallpaperPlatformService                │
└──────────────────────────────▲──────────────────────────────┘
                               │ (implements)
┌──────────────────────────────┴──────────────────────────────┐
│                          DATA LAYER                         │
│  10 Data Sources  •  WallpaperRepositoryImpl  •  Cache Model │
│   Native FFI: WindowsWallpaperService (user32.dll kernel hook)  │
└─────────────────────────────────────────────────────────────┘
```

- **Separation of Concerns**: Pure Dart domain layer has zero dependency on UI or Flutter SDK.
- **Platform Isolation**: Win32 FFI calls live strictly behind the `IWallpaperPlatformService` interface, enabling painless porting to macOS (`NSWorkspace`) and Linux (`gsettings`).
- **Resilience**: Any remote datasource failure degrades gracefully into curated offline fallbacks without disrupting the active card stack.

---

## 🚀 Quickstart

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.24+ recommended)
- Windows 10/11 with Developer Mode or C++ build tools

### Build & Run Locally
```bash
# Clone the repository
git clone https://github.com/arashgholiyan/wall-gem.git
cd wall-gem

# Fetch dependencies
flutter pub get

# Launch on Windows Desktop
flutter run -d windows
```

### Verification & Testing
```bash
# Run static analysis
flutter analyze

# Execute 35 hermetic unit & widget tests
flutter test
```

---

## 🤝 Let's Collaborate & Build Together!

Wall Gem is an open-source initiative designed to prove that desktop utility apps can be fast, gorgeous, and respectful of user privacy.

I'm actively looking to collaborate with other passionate developers in the FOSS community. Here are areas where contributions are warmly welcomed:
- 🐧 **Linux & macOS Support**: Implementing native wallpaper setters (`gsettings` / `feh` for Linux, `NSWorkspace` for macOS).
- 🖥️ **Multi-Monitor Customization**: Independent wallpapers per display monitor via Win32 desktop COM interfaces.
- 🏷️ **Custom Tag Filtering & Search**: On-the-fly keyword filtering across community APIs.

If you have ideas, feedback, or want to collaborate on this or future projects, let's connect!

- **Creator**: [Arash Gholiyan](https://github.com/arashgholiyan)
- **Issues & Discussions**: Feel free to open an [Issue](https://github.com/arashgholiyan/wall-gem/issues) or start a conversation.
- **Pull Requests**: Check out [CONTRIBUTING.md](CONTRIBUTING.md) — PRs of all sizes are welcome.

---

## ⚖️ Legal, Copyright & Trademark Notice

### 1. Non-Hosting & Client-Side Operation
Wall Gem is an open-source, client-side indexing and desktop personalization utility. **Wall Gem does not host, store, cache on remote servers, or redistribute any copyrighted media or image files.** All media assets, thumbnails, and images are retrieved directly on demand by the end-user's device from publicly accessible third-party endpoints and content delivery networks.

### 2. Intellectual Property & Copyright Ownership
All images, artwork, photography, and wallpapers accessible through this client remain the exclusive intellectual property and copyright of their respective authors, photographers, creators, and platforms. Display within Wall Gem does not grant or imply any transfer of ownership or licensing rights.

### 3. Fair Use & Educational Purpose
This software is provided for personal, non-commercial, and educational purposes under the [MIT License](LICENSE). The indexing of publicly accessible web feeds is performed in good faith under fair use doctrine.

### 4. Trademark Notice
*Windows* and *Microsoft* are registered trademarks of Microsoft Corporation. All other trademarks, service marks, trade names, and logos referenced or displayed within this repository and application belong to their respective owners. Wall Gem is an independent open-source project and is not affiliated with, endorsed by, or sponsored by any referenced company or platform.

### 5. Content Removal & Takedown Requests
If you are a copyright holder, artist, or platform administrator and wish to request the exclusion or removal of your content feed or domain from Wall Gem's default indexer, please open a GitHub Issue or contact the maintainer at [github.com/arashgholiyan](https://github.com/arashgholiyan). Your request will be honored and the source endpoint will be promptly removed from the codebase within 24–48 hours.

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.
