# Contributing to Wall Gem 💎

Thank you for your interest in contributing to **Wall Gem**! We welcome bug fixes, documentation improvements, new wallpaper source providers, and UI enhancements.

## Code of Conduct

Please be respectful and constructive in all issues, pull requests, and discussions.

## Getting Started

1. **Fork & Clone**
   ```bash
   git clone https://github.com/arashgholiyan/wall-gem.git
   cd wall-gem
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run -d windows
   ```

## Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/my-new-source
   ```
2. Adhere to Clean Architecture:
   - **Domain**: Define abstract repository or service interfaces in `lib/domain/`.
   - **Data**: Implement remote sources and DTOs in `lib/data/`.
   - **Presentation**: Wire business logic in `lib/presentation/providers/`.
3. Write unit and widget tests for any new logic under `test/unit/` or `test/widget/`.
4. Ensure all formatting and analysis checks pass:
   ```bash
   dart format --set-exit-if-changed .
   flutter analyze --fatal-infos
   flutter test
   ```
5. Submit a Pull Request describing your changes.
