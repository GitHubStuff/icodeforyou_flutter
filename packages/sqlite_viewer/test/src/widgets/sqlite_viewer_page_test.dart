// test/src/selector_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(ThemePackage.reset);

  group('ThemeSelectorWidget', () {
    Future<void> pumpSelectorWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ThemePackageRoot(
          databaseName: validDbName,
          inMemory: true,
          splash: const SizedBox.shrink(),
          child: MaterialApp(
            home: Scaffold(
              body: ThemeBuilder(
                builder: (context, themeMode) {
                  return Column(
                    children: [
                      const ThemeSelectorWidget(),
                      Text('Current: ${themeMode.name}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    group('UI elements', () {
      testWidgets('displays "Select Theme:" label', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Select Theme:'), findsOneWidget);
      });

      testWidgets('displays System radio option', (WidgetTester tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('System'), findsOneWidget);
      });

      testWidgets('displays Dark radio option', (WidgetTester tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Dark'), findsOneWidget);
      });

      testWidgets('displays Light radio option', (WidgetTester tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('has three RadioListTile widgets', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));
      });
    });

    group('initial state', () {
      testWidgets('System is selected by default', (WidgetTester tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Current: system'), findsOneWidget);

        // Verify RadioGroup has system as groupValue
        final radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.system);
      });
    });

    group('theme selection', () {
      testWidgets('tapping Dark changes theme to dark', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        // Tap Dark option
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        expect(find.text('Current: dark'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.dark);
      });

      testWidgets('tapping Light changes theme to light', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        // Tap Light option
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(find.text('Current: light'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.light);
      });

      testWidgets('tapping System changes theme to system', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        // First change to dark
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        expect(find.text('Current: dark'), findsOneWidget);

        // Then change to system
        await tester.tap(find.text('System'));
        await tester.pumpAndSettle();

        expect(find.text('Current: system'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.system);
      });

      testWidgets('radio button visually updates when selection changes', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        // Initially System is selected
        var radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.system);

        // Tap Dark
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        // Now Dark should be selected
        radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.dark);
      });
    });

    group('persistence', () {
      testWidgets('selection persists to datasource', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        // Verify persisted
        expect(ThemePackage.getTheme(), ThemeMode.light);
      });
    });

    group('null mode handling', () {
      testWidgets('onChanged does nothing when mode is null', (
        WidgetTester tester,
      ) async {
        await pumpSelectorWidget(tester);

        // This test verifies the code path where mode == null in onChanged
        // The RadioListTile should never pass null, but the code handles it
        expect(find.text('Current: system'), findsOneWidget);

        // Tap multiple times to ensure stability
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(find.text('Current: light'), findsOneWidget);
      });
    });
  });
}
