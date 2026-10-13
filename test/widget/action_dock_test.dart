import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_gem/core/constants/app_keys.dart';
import 'package:wall_gem/presentation/widgets/common/action_dock.dart';

void main() {
  testWidgets(
    'ActionDock renders all 5 action buttons and triggers callbacks',
    (WidgetTester tester) async {
      bool passed = false;
      bool liked = false;
      bool starred = false;
      bool undo = false;
      bool preview = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionDock(
              onPass: () => passed = true,
              onLike: () => liked = true,
              onStar: () => starred = true,
              onUndo: () => undo = true,
              onPreview: () => preview = true,
              canUndo: true,
            ),
          ),
        ),
      );

      expect(find.byKey(AppKeys.passButton), findsOneWidget);
      expect(find.byKey(AppKeys.likeButton), findsOneWidget);
      expect(find.byKey(AppKeys.starButton), findsOneWidget);
      expect(find.byKey(AppKeys.undoButton), findsOneWidget);
      expect(find.byKey(AppKeys.previewButton), findsOneWidget);

      await tester.tap(find.byKey(AppKeys.likeButton));
      await tester.tap(find.byKey(AppKeys.passButton));
      await tester.tap(find.byKey(AppKeys.starButton));
      await tester.tap(find.byKey(AppKeys.undoButton));
      await tester.tap(find.byKey(AppKeys.previewButton));

      expect(liked, isTrue);
      expect(passed, isTrue);
      expect(starred, isTrue);
      expect(undo, isTrue);
      expect(preview, isTrue);
    },
  );
}
