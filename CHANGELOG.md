# Changelog

All notable changes to **Wall Gem** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.3.0] - 2026-10-14

### *Wall Gem v1.3.0 — The Glassmorphic Desktop & Ergonomics Edition 💎*

#### ⌨️ Keyboard Shortcuts Cheatsheet Modal (`?` / `F1`)
- **Glassmorphic Hotkey Modal**: Press <kbd>?</kbd>, <kbd>Shift + /</kbd>, or <kbd>F1</kbd> anywhere in the application (or click the new Help button in the header bar) to bring up a keyboard shortcut overlay.
- **Categorized Shortcuts**: Grouped into **Navigation & Exploration**, **Wallpaper Actions**, **View & Modals**, and **Palette & Ricing**.
- **Interactive Search**: Real-time filtering within the modal allows instant lookup of any keybinding.
- **Platform-Aware Key Glyphs**: Displays platform-native key representations (<kbd>Ctrl</kbd> on Windows/Linux vs. <kbd>⌘</kbd> on macOS).

#### 🎨 21st.dev & Raycast-Caliber Glassmorphic UI
- **Floating Frosted Action Dock**: Redesigned floating dock with dual-stage backdrop blur (`BackdropFilter`), ambient drop shadow, border luminance, and animated hover micro-interactions.
- **Luminous Accent Action**: The primary *Set Wallpaper* button now features a glowing accent.
- **Ambient Card Backlight Glow**: Wallpaper cards dynamically cast a soft, diffused backlight glow sampled from their dominant color palette.
- **Frosted Badges & Chips**: Translucent card tags, category pills, and count chips with refined typography and micro-borders.
- **Raycast/Linear Command Bar**: The Favorites Vault search input now features a glassmorphic command bar with dynamic keyboard hints.
- **Animated View-Mode Pill**: Polished segmented control for toggling between `[ 🃏 Deck ]` and `[ 🏛️ Vault ]` with smooth sliding indicator and count chip.
- **Neon Batch Progress Bar**: Integrated 1px ambient glowing progress indicator along the header edge to track batch progress.

#### 🖥️ Cross-Platform Ergonomics & Native Integrations
- **Universal `PlatformShortcuts`**: Dynamically switches shortcut badges between `Ctrl+K` on Windows/Linux and `⌘K` on macOS.
- **Desktop Drag-Scroll Physics (`DesktopScrollBehavior`)**: Smooth multi-input scrolling across mouse drag, touchpads, touchscreens, and trackballs.
- **Universal ESC Dismissal**: Consistent Escape key dismissal across all modals, preview dialogs, palette export sheets, and the shortcuts cheatsheet.
- **Wayland Wallpaper Engine Support**: Extended `LinuxWallpaperService` with native support for `swww` and `hyprpaper` wallpaper daemons for Wayland and Hyprland compositors, complementing existing GNOME, KDE Plasma, XFCE, and `feh` runners.
- **Ultrawide & Multi-Monitor Responsive Grid**: Dynamic column scaling supporting 1 column on compact laptop windows up to 7 columns on 21:9 and 32:9 displays.

---

## [1.2.0] - 2026-10-13

### *Wall Gem v1.2.0 — The Community Flagship Edition 💎*

#### Added
- **Favorites Vault (Local Gallery Grid)**: Full local gallery view with instant search, category filtering, and human-readable JSON persistence (`Pictures/WallGem/favorites.json`).
- **Dynamic Color Palette & Ricing Exporter**: Extract dominant 5-color palettes and export instantly to Pywal (`.Xresources`), CSS custom properties (`:root`), JSON, or Hex CSV with visual swatches.
- **Day & Night Dynamic Sun Cycle**: Automatically shifts recommendations based on time of day (bright nature/architecture by day, AMOLED dark/cyberpunk/space by night).
- **Scheduled Interval Auto-Cycler**: Background wallpaper cycler with selectable intervals (*15m*, *30m*, *1h*, *4h*) and clean lifecycle timer disposal.
- **Multi-Monitor & Ultrawide Splitter**: Flags 21:9 and 32:9 panoramic wallpapers and calculates Left/Right display bisection slices saved to `Pictures/WallGem/MultiMonitor/`.
- **Progressive Dual-Layer Photo Loading**: Instant thumbnail preview layer coupled with high-resolution caching for zero-blur transitions.

---

## [1.1.0] - 2026-10-13

### *Wall Gem v1.1.0 — 10 Sources, Zero Keys 💎*

#### Added
- Multi-provider wallpaper aggregation: Wallhaven, Unsplash, Pexels, Bing Daily, NASA APOD, Wikimedia Commons, Openverse, and Reddit r/wallpapers.
- Zero-API-key architecture with graceful fallback cascades.
- Offline thumbnail disk cache for rapid re-opening.

---

## [1.0.0] - 2026-10-13

### *Wall Gem v1.0.0 — The First Cut 💎*

#### Added
- Initial public release of Wall Gem.
- Gesture-driven 60 FPS 3D card deck exploration.
- Native Win32 C-FFI kernel hooks (`user32.dll`) for <50ms wallpaper application.
- Clean Architecture with Domain, Data, and Presentation separation.
