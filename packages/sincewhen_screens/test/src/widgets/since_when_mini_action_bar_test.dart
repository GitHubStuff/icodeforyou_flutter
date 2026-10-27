// packages/sincewhen_screens/test/src/widgets/since_when_mini_action_bar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/src/cubit/state.dart';
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart';
import 'package:sincewhen_screens/src/widgets/since_when_mini_action_bar.dart';

void main() {
  group('SinceWhenMiniActionBar', () {
    test('cancelLabel is Cancel', () {
      expect(SinceWhenMiniActionBar.cancelLabel, equals('Cancel'));
    });

    testWidgets('renders Cancel button and calls onCancelPressed when tapped', (
      tester,
    ) async {
      var cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SinceWhenMiniActionBar(
              primaryAction: SinceWhenMiniAction.submit,
              isPrimaryEnabled: true,
              onPrimaryPressed: () {},
              onCancelPressed: () {
                cancelCalled = true;
              },
            ),
          ),
        ),
      );

      final cancelButtonFinder = find.widgetWithText(
        OutlinedButton,
        SinceWhenMiniActionBar.cancelLabel,
      );
      expect(cancelButtonFinder, findsOneWidget);

      await tester.tap(cancelButtonFinder);
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets(
      'renders enabled primary button with matching label and triggers onPrimaryPressed',
      (tester) async {
        for (final action in SinceWhenMiniAction.values) {
          var primaryCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinceWhenMiniActionBar(
                  primaryAction: action,
                  isPrimaryEnabled: true,
                  onPrimaryPressed: () {
                    primaryCalled = true;
                  },
                  onCancelPressed: () {},
                ),
              ),
            ),
          );

          final primaryButtonFinder = find.widgetWithText(
            FilledButton,
            action.label,
          );
          expect(primaryButtonFinder, findsOneWidget);

          final buttonWidget = tester.widget<FilledButton>(primaryButtonFinder);
          expect(buttonWidget.onPressed, isNotNull);

          await tester.tap(primaryButtonFinder);
          await tester.pump();

          expect(primaryCalled, isTrue);
        }
      },
    );

    testWidgets(
      'disables primary button when isPrimaryEnabled is false and ignores taps',
      (tester) async {
        var primaryCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SinceWhenMiniActionBar(
                primaryAction: SinceWhenMiniAction.submit,
                isPrimaryEnabled: false,
                onPrimaryPressed: () {
                  primaryCalled = true;
                },
                onCancelPressed: () {},
              ),
            ),
          ),
        );

        final primaryButtonFinder = find.widgetWithText(
          FilledButton,
          SinceWhenMiniAction.submit.label,
        );
        expect(primaryButtonFinder, findsOneWidget);

        final buttonWidget = tester.widget<FilledButton>(primaryButtonFinder);
        expect(buttonWidget.onPressed, isNull);

        await tester.tap(primaryButtonFinder);
        await tester.pump();

        expect(primaryCalled, isFalse);
      },
    );

    testWidgets('renders Gap with expected button gap dimension', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SinceWhenMiniActionBar(
              primaryAction: SinceWhenMiniAction.update,
              isPrimaryEnabled: true,
              onPrimaryPressed: () {},
              onCancelPressed: () {},
            ),
          ),
        ),
      );

      final gapFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Gap &&
            widget.mainAxisExtent == SinceWhenMiniDimensions.actionBarButtonGap,
      );
      expect(gapFinder, findsOneWidget);
    });
  });
}
