# Contributing to Wall Gem 💎

First off, thank you for considering contributing to **Wall Gem**! 

Whether you're fixing a typo in documentation, reporting a weird layout edge-case, writing a native wallpaper setter for your favorite Linux desktop environment, or adding a new wallpaper feed, every contribution makes this project better for everyone.

---

## 🤝 Community Philosophy

We believe open source should be fun, welcoming, and collaborative. No contribution is too small!
- Never contributed to Flutter or Dart before? We're happy to guide you through your first PR.
- Found a bug? Open an issue with reproduction steps and we'll investigate together.
- Have an idea for a new feature or aesthetic category? Let's discuss it in GitHub Issues or Discussions!

Please make sure to review our [Code of Conduct](CODE_OF_CONDUCT.md) to keep our community respectful and encouraging.

---

## 🛠️ Setting Up Your Development Environment

### 1. Prerequisites
- **Flutter SDK**: v3.24+ (stable channel)
- **Dart SDK**: v3.10+ (bundled with Flutter)
- A desktop environment: Windows 10/11, macOS, or Linux

### 2. Fork and Clone
```bash
# Clone your fork
git clone https://github.com/<your-username>/wall-gem.git
cd wall-gem

# Fetch dependencies
flutter pub get

# Run on desktop
flutter run -d windows
```

---

## 🏗️ Architecture & Project Structure

Wall Gem strictly adheres to **Clean Architecture** with unidirectional data flow:

```
lib/
├── core/             # Shared constants, themes, color tokens, and error types
├── data/
│   ├── datasources/  # Concrete remote parsers (10 providers)
│   ├── models/       # Data transfer objects (WallpaperModel)
│   ├── repositories/ # Repositories combining data sources
│   └── services/     # Native OS wallpaper services (Win32 FFI, macOS, Linux)
├── domain/
│   ├── entities/     # Pure Dart entities (Wallpaper, FavoriteWallpaper)
│   └── repositories/ # Abstract repository & service contracts
└── presentation/
    ├── providers/    # State controllers (ChangeNotifier / Provider)
    ├── views/        # Top-level screen views (HomeScreen)
    └── widgets/      # Reusable UI components (deck, vault, dock, palette)
```

### 💡 Example: Adding a New Wallpaper Source in 10 Minutes
1. Create a parser in `lib/data/datasources/my_source.dart`.
2. Map incoming data to `WallpaperModel`.
3. Add the platform name to `AppConstants.sources` in `lib/core/constants/app_constants.dart`.
4. Register the datasource inside `WallpaperRepositoryImpl` (`lib/data/repositories/wallpaper_repository_impl.dart`).
5. Add hermetic unit tests in `test/unit/data/my_source_test.dart` using `MockHttpClient`.
6. Run `flutter test` to ensure it passes!

---

## 🧪 Testing & Code Quality Guidelines

We take automated testing and code hygiene seriously to ensure regressions never slip into releases:

Before submitting your PR, make sure these three commands pass cleanly:

```bash
# 1. Format all code cleanly
dart format .

# 2. Verify static analysis
flutter analyze

# 3. Run the automated test suite
flutter test
```

### Testing Rules:
- **Zero Real Network Requests in Tests**: Always inject `MockHttpClient` or fake data sources.
- **Hermetic File Operations**: If testing file persistence, write to a temporary test directory created via `Directory.systemTemp.createTemp()`.

---

## 📬 Submitting a Pull Request

1. Create a descriptive feature branch:
   ```bash
   git checkout -b feat/wayland-swww-setter
   ```
2. Commit your changes with clear, human commit messages:
   ```bash
   git commit -m "feat(linux): add swww wallpaper setter for Wayland desktops"
   ```
3. Push your branch to GitHub and open a Pull Request using our [PR Template](.github/PULL_REQUEST_TEMPLATE.md).
4. We'll review your PR, offer constructive feedback, and merge once tests pass!

Thank you for helping build a better, faster, and more respectful desktop wallpaper engine! 💎
