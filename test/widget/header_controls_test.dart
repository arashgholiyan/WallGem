import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/core/constants/app_keys.dart';
import 'package:wall_gem/core/theme/app_colors.dart';
import 'package:wall_gem/presentation/providers/wallpaper_deck_provider.dart';
import 'package:wall_gem/presentation/widgets/common/header_bar.dart';

void main() {
  Widget buildHeaderBar({
    int likedCount = 3,
    String activeSource = 'All Sources',
    ValueChanged<String>? onSelectSource,
    VoidCallback? onOpenFolder,
    ViewMode activeViewMode = ViewMode.deck,
    ValueChanged<ViewMode>? onSelectViewMode,
    int favoritesCount = 5,
    bool isDayNightEnabled = false,
    VoidCallback? onToggleDayNight,
    Duration? autoCycleInterval,
    ValueChanged<Duration?>? onSelectAutoCycleInterval,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HeaderBar(
          likedCount: likedCount,
          activeSource: activeSource,
          onSelectSource: onSelectSource ?? (_) {},
          onOpenFolder: onOpenFolder ?? () {},
          activeViewMode: activeViewMode,
          onSelectViewMode: onSelectViewMode,
          favoritesCount: favoritesCount,
          isDayNightEnabled: isDayNightEnabled,
          onToggleDayNight: onToggleDayNight,
          autoCycleInterval: autoCycleInterval,
          onSelectAutoCycleInterval: onSelectAutoCycleInterval,
        ),
      ),
    );
  }

  group('HeaderBar ViewMode Toggle Controls', () {
    testWidgets(
      'renders Deck and Vault segments and triggers onSelectViewMode when switched to Vault',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        ViewMode? selectedMode;

        await tester.pumpWidget(
          buildHeaderBar(
            activeViewMode: ViewMode.deck,
            favoritesCount: 7,
            onSelectViewMode: (mode) => selectedMode = mode,
          ),
        );

        // Verify segment labels
        expect(find.text('🃏 Deck'), findsOneWidget);
        expect(find.text('🏛️ Vault (7)'), findsOneWidget);

        // Tap Vault segment
        await tester.tap(find.text('🏛️ Vault (7)'));
        await tester.pumpAndSettle();

        expect(selectedMode, equals(ViewMode.vault));
      },
    );

    testWidgets(
      'triggers onSelectViewMode when switched from Vault back to Deck',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        ViewMode? selectedMode;

        await tester.pumpWidget(
          buildHeaderBar(
            activeViewMode: ViewMode.vault,
            favoritesCount: 12,
            onSelectViewMode: (mode) => selectedMode = mode,
          ),
        );

        // Tap Deck segment
        await tester.tap(find.text('🃏 Deck'));
        await tester.pumpAndSettle();

        expect(selectedMode, equals(ViewMode.deck));
      },
    );

    testWidgets(
      'visually highlights the active segment with primary color',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildHeaderBar(
            activeViewMode: ViewMode.deck,
            favoritesCount: 3,
          ),
        );

        // Find AnimatedContainer wrapping '🃏 Deck'
        final deckContainerFinder = find.ancestor(
          of: find.text('🃏 Deck'),
          matching: find.byType(AnimatedContainer),
        );
        expect(deckContainerFinder, findsOneWidget);

        final deckContainer = tester.widget<AnimatedContainer>(deckContainerFinder);
        final deckDecoration = deckContainer.decoration as BoxDecoration;
        expect(deckDecoration.color, equals(AppColors.primary));

        // Find AnimatedContainer wrapping '🏛️ Vault (3)'
        final vaultContainerFinder = find.ancestor(
          of: find.text('🏛️ Vault (3)'),
          matching: find.byType(AnimatedContainer),
        );
        expect(vaultContainerFinder, findsOneWidget);

        final vaultContainer = tester.widget<AnimatedContainer>(vaultContainerFinder);
        final vaultDecoration = vaultContainer.decoration as BoxDecoration;
        expect(vaultDecoration.color, equals(Colors.transparent));
      },
    );
  });

  group('HeaderBar Day & Night Sun Cycle Controls', () {
    testWidgets(
      'displays moon icon and off tooltip when disabled, and calls onToggleDayNight on tap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        bool toggled = false;

        await tester.pumpWidget(
          buildHeaderBar(
            isDayNightEnabled: false,
            onToggleDayNight: () => toggled = true,
          ),
        );

        expect(find.text('🌙'), findsOneWidget);
        expect(find.byTooltip('Sun Cycle Off (Tap to sync dynamic themes)'), findsOneWidget);

        await tester.tap(find.text('🌙'));
        await tester.pumpAndSettle();

        expect(toggled, isTrue);
      },
    );

    testWidgets(
      'displays sun icon and active tooltip when enabled, and calls onToggleDayNight on tap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        bool toggled = false;

        await tester.pumpWidget(
          buildHeaderBar(
            isDayNightEnabled: true,
            onToggleDayNight: () => toggled = true,
          ),
        );

        expect(find.text('☀️'), findsOneWidget);
        expect(find.byTooltip('Sun Cycle Active (Syncing with Day/Night)'), findsOneWidget);

        await tester.tap(find.text('☀️'));
        await tester.pumpAndSettle();

        expect(toggled, isTrue);
      },
    );
  });

  group('HeaderBar Scheduled Interval Auto-Cycler Dropdown', () {
    testWidgets(
      'displays "⏱️ Timer: Off" by default and lets user select 15m cycle',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        Duration? chosenInterval;

        await tester.pumpWidget(
          buildHeaderBar(
            autoCycleInterval: null,
            onSelectAutoCycleInterval: (val) => chosenInterval = val,
          ),
        );

        expect(find.text('⏱️ Timer: Off'), findsOneWidget);

        // Tap dropdown to open menu
        await tester.tap(find.text('⏱️ Timer: Off'));
        await tester.pumpAndSettle();

        // Verify dropdown items
        expect(find.text('⏱️ Cycle: 15m'), findsOneWidget);
        expect(find.text('⏱️ Cycle: 30m'), findsOneWidget);
        expect(find.text('⏱️ Cycle: 1h'), findsOneWidget);
        expect(find.text('⏱️ Cycle: 4h'), findsOneWidget);

        // Select 15m
        await tester.tap(find.text('⏱️ Cycle: 15m'));
        await tester.pumpAndSettle();

        expect(chosenInterval, equals(const Duration(minutes: 15)));
      },
    );

    testWidgets(
      'displays "⏱️ Cycle: 30m" and allows changing to 1h',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        Duration? chosenInterval;

        await tester.pumpWidget(
          buildHeaderBar(
            autoCycleInterval: const Duration(minutes: 30),
            onSelectAutoCycleInterval: (val) => chosenInterval = val,
          ),
        );

        expect(find.text('⏱️ Cycle: 30m'), findsOneWidget);

        await tester.tap(find.text('⏱️ Cycle: 30m'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('⏱️ Cycle: 1h'));
        await tester.pumpAndSettle();

        expect(chosenInterval, equals(const Duration(hours: 1)));
      },
    );

    testWidgets(
      'allows turning auto-cycler Off from an active interval',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        Duration? chosenInterval = const Duration(hours: 4);

        await tester.pumpWidget(
          buildHeaderBar(
            autoCycleInterval: const Duration(hours: 4),
            onSelectAutoCycleInterval: (val) => chosenInterval = val,
          ),
        );

        expect(find.text('⏱️ Cycle: 4h'), findsOneWidget);

        await tester.tap(find.text('⏱️ Cycle: 4h'));
        await tester.pumpAndSettle();

        // Select '⏱️ Timer: Off'
        await tester.tap(find.text('⏱️ Timer: Off').last);
        await tester.pumpAndSettle();

        expect(chosenInterval, isNull);
      },
    );
  });

  group('HeaderBar General Navigation & Responsiveness', () {
    testWidgets(
      'triggers onOpenFolder when folder icon is tapped',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        bool folderOpened = false;

        await tester.pumpWidget(
          buildHeaderBar(onOpenFolder: () => folderOpened = true),
        );

        expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
        await tester.tap(find.byIcon(Icons.folder_open_outlined));
        await tester.pumpAndSettle();

        expect(folderOpened, isTrue);
      },
    );

    testWidgets(
      'renders without overflow on compact 800x600 screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildHeaderBar(
            activeViewMode: ViewMode.deck,
            favoritesCount: 3,
          ),
        );

        expect(find.byKey(AppKeys.headerBar), findsOneWidget);
        expect(find.text('🃏 Deck'), findsOneWidget);
        expect(find.text('🏛️ Vault (3)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
