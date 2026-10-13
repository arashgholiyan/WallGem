# Wall Gem Flagship Features Specification

**Date:** 2026-10-13  
**Status:** Draft  
**Scope:** Architectural Expansion  
**Author:** Arash Gholiyan / Antigravity

---

## 1. Overview & Objectives

Wall Gem is being expanded from a gesture discovery deck into a comprehensive, community-grade desktop wallpaper suite. This specification details the architecture, data models, state flows, and UI contracts for 5 flagship features:

1. **🏛️ Favorites Vault**: Persistent local wallpaper library with in-window view switching (`[ 🃏 Deck ] [ 🏛️ Vault (N) ]`), responsive masonry grid, keyword search, and 1-click wallpaper application.
2. **🎨 Dynamic Color Palette & "Ricing" Exporter**: Extraction and 1-click clipboard export of 5-color palettes into **Pywal** (`.Xresources`), **CSS Variables**, **JSON**, and **Hex CSV**, plus dynamic ambient glow tinting.
3. **☀️/🌙 "Day & Night" Dynamic Sun Cycle**: Time-aware discovery mode automatically prioritizing bright nature and landscapes during daytime (06:00–19:59) and switching to OLED Dark, Cyberpunk, and deep space at night (20:00–05:59).
4. **⏱️ Scheduled Interval Auto-Cycler**: Background timer engine (*Off*, *15m*, *30m*, *1h*, *4h*, *Daily*) that automatically advances and applies wallpapers from the liked library or active feed.
5. **🖥️ Multi-Monitor & Ultrawide Splitter**: Dual-monitor utility that detects 21:9 and 32:9 panoramic aspect ratios and splits them into discrete Left Display and Right Display images.

---

## 2. Architecture & Layering

Wall Gem strictly adheres to **Clean Architecture**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                            │
│  HomeScreen (Deck View vs Vault View) • HeaderBar (Switcher, Mode, ⏱️)  │
│     FavoritesVaultView (Search, Grid, Actions) • PaletteExportModal    │
│           Providers: WallpaperDeckProvider, FavoritesProvider          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                             DOMAIN LAYER                               │
│           Entities: Wallpaper, FavoriteWallpaper, ColorPalette         │
│     Interfaces: IFavoritesRepository, IWallpaperPlatformService        │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │
┌───────────────────────────────────┴────────────────────────────────────┐
│                              DATA LAYER                                │
│       FavoritesJsonStorageService (Pictures/WallGem/favorites.json)    │
│     PaletteFormatService (Pywal, CSS, JSON) • MultiMonitorService      │
│          Universal Wallpaper Platform Services (Win/Mac/Linux)         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Detailed Subsystem Specifications

### Subsystem 1: Favorites Vault & JSON Persistence

#### Storage Specification
- **Location**: `Pictures/WallGem/favorites.json`
- **Schema**:
```json
{
  "version": 1,
  "favorites": [
    {
      "id": "wide_epic_mountain",
      "title": "Epic Mountain Ridge",
      "author": "Alex Perez (Unsplash / Public Domain)",
      "sourceName": "wallpaperswide.com",
      "thumbUrl": "https://...",
      "fullUrl": "https://...",
      "localFilePath": "C:\\Users\\...\\Pictures\\WallGem\\Slideshow\\wide_epic_mountain.jpg",
      "resolution": "3840x2160 (4K UHD)",
      "ratio": "16:9",
      "category": "Landscape",
      "colors": [4284704497, 4279261003],
      "savedAt": "2026-10-13T15:30:00.000Z"
    }
  ]
}
```
- **Operations**:
  - `loadFavorites()`: Asynchronously reads and parses JSON. If missing or corrupted, returns an empty list safely without throwing.
  - `saveFavorite(Wallpaper)`: Prepends to favorites, ensures unique ID, downloads the full image locally if not already cached, and writes formatted JSON atomically.
  - `removeFavorite(id)`: Removes item from JSON and optionally deletes cached local file.

#### Vault UI Contract
- Header bar includes a responsive pill switcher:
  - `[ 🃏 Deck ]` (active by default)
  - `[ 🏛️ Vault (N) ]` (displays live badge count of saved wallpapers)
- Selecting `Vault` smoothly cross-fades the central area into `FavoritesVaultView`:
  - **Search & Filter Header**: Real-time keyword filter input + Category chips.
  - **Masonry Grid**: Responsive 2, 3, or 4 columns based on window width.
  - **Card Overlay Actions**:
    - `⚡ Apply Now`: Sets as desktop wallpaper immediately in <100ms.
    - `🎨 Palette`: Opens color export menu.
    - `📁 File`: Opens in native file explorer (`explorer.exe` / `open` / `xdg-open`).
    - `🗑️ Delete`: Confirms and removes from Vault.

---

### Subsystem 2: Dynamic Color Palette & "Ricing" Exporter

#### Palette Extraction & Formats
Wall Gem leverages the extracted `dominantColors` on every wallpaper to generate 4 industry-standard formats:

1. **Pywal (`.Xresources`)**:
```text
! Generated by Wall Gem for Pywal / Ricing
*background: #06070A
*foreground: #F8FAFC
*color0: #06070A
*color1: #6366F1
*color2: #38BDF8
*color3: #10B981
*color4: #F59E0B
*color5: #EC4899
*color6: #38BDF8
*color7: #F8FAFC
```
2. **CSS Variables**:
```css
:root {
  --wg-bg: #06070a;
  --wg-fg: #f8fafc;
  --wg-accent-1: #6366f1;
  --wg-accent-2: #38bdf8;
  --wg-accent-3: #10b981;
}
```
3. **JSON Palette**:
```json
{
  "theme": "Wall Gem Extracted Palette",
  "background": "#06070a",
  "accent": "#6366f1",
  "palette": ["#6366f1", "#38bdf8", "#10b981", "#f59e0b", "#ec4899"]
}
```
4. **Hex CSV**: `#6366F1, #38BDF8, #10B981, #F59E0B, #EC4899`

#### UI Interaction
- In `WallpaperPreviewDialog` (Lightbox) and on Vault cards, a **"🎨 Export Palette"** button opens a popover or bottom sheet allowing 1-click clipboard copy with snackbar feedback.
- **Ambient UI Tint**: When enabled in settings, the header glow and active card borders softly interpolate toward the wallpaper's primary dominant color.

---

### Subsystem 3: "Day & Night" Dynamic Sun Cycle

#### Behavior
- Accessible via a toggle icon in the header: `☀️ Day` (active during 06:00–19:59) / `🌙 Night` (active during 20:00–05:59).
- **Automatic Scheduling**:
  - During **Daytime**: The discovery engine prioritizes `Landscape`, `Architecture`, and bright nature photography.
  - During **Nighttime**: The engine automatically switches to `OLED Dark`, `Cyberpunk`, and `Space`.
- Users can manually override at any time by selecting specific category chips.

---

### Subsystem 4: Scheduled Interval Auto-Cycler

#### Engine Design
- Managed by `WallpaperDeckProvider`:
  - Timer intervals: `Duration? autoCycleInterval` (Options: `Off`, `15m`, `30m`, `1h`, `4h`, `24h`).
  - Active timer executes:
    1. If Vault contains >= 3 favorites, rotates through the saved favorites sequentially or randomly.
    2. If Vault is empty, advances the top card of the current category deck and applies it to the desktop.
- Header bar displays a subtle indicator when active: `[ ⏱️ 30m ]`.

---

### Subsystem 5: Multi-Monitor & Ultrawide Panoramic Splitter

#### Slicing Specification
- For wallpapers with aspect ratios >= `21:9` (e.g. 3840×1600, 5120×1440, 5120×2160):
  - Provides a **"🖥️ Split for Dual Screens"** utility.
  - Mathematically bisects the image along the horizontal axis into two distinct files:
    - `filename_left.jpg` (Displays on Monitor 1)
    - `filename_right.jpg` (Displays on Monitor 2)
  - Saved to `Pictures/WallGem/MultiMonitor/`.
  - On Windows, uses native `SystemParametersInfoW` or displays the directory for instant dual-screen assignment in Windows Personalization.

---

## 4. Test Strategy & Acceptance Criteria

1. **Favorites Storage Test (`test/unit/data/favorites_storage_test.dart`)**:
   - Verify serialization/deserialization to/from JSON.
   - Verify duplicate ID prevention.
   - Verify non-blocking error handling on invalid JSON.
2. **Palette Formatter Test (`test/unit/data/palette_formatter_test.dart`)**:
   - Verify correct Pywal, CSS, JSON, and Hex output from color list.
3. **Day & Night Calculator Test (`test/unit/core/day_night_calculator_test.dart`)**:
   - Verify day vs. night categorization across 24 hour inputs.
4. **Auto-Cycler Interval Test (`test/unit/presentation/auto_cycler_test.dart`)**:
   - Verify timer triggering, pause on dispose, and interval updates.
5. **Widget Tests (`test/widget/vault_view_test.dart`)**:
   - Verify view switcher switches between Deck and Vault without overflow.
   - Verify search bar filtering on Vault grid.
6. **Zero Analyzer Warnings**: `flutter analyze` must report 0 issues.
7. **Complete Suite**: All 46+ tests must pass hermetically without network requirements.
