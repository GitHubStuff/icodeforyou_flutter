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
      testWidgets('can be constructed with a key', (tester) async {
        await tester.pumpWidget(
          const ThemePackageRoot(
            databaseName: validDbName,
            inMemory: true,
            splash: SizedBox.shrink(),
            child: MaterialApp(
              home: Scaffold(
                body: ThemeSelectorWidget(key: Key('selector')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('selector')), findsOneWidget);
      });

      testWidgets('displays "Select Theme:" label', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Select Theme:'), findsOneWidget);
      });

      testWidgets('displays System radio option', (tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('System'), findsOneWidget);
      });

      testWidgets('displays Dark radio option', (tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Dark'), findsOneWidget);
      });

      testWidgets('displays Light radio option', (tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('has three RadioListTile widgets', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));
      });
    });

    group('initial state', () {
      testWidgets('System is selected by default', (tester) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Current: system'), findsOneWidget);

        final radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.system);
      });
    });

    group('theme selection', () {
      testWidgets('tapping Dark changes theme to dark', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        expect(find.text('Current: dark'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.dark);
      });

      testWidgets('tapping Light changes theme to light', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(find.text('Current: light'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.light);
      });

      testWidgets('tapping System changes theme to system', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        expect(find.text('Current: dark'), findsOneWidget);

        await tester.tap(find.text('System'));
        await tester.pumpAndSettle();

        expect(find.text('Current: system'), findsOneWidget);
        expect(ThemePackage.currentTheme, ThemeMode.system);
      });

      testWidgets('radio button visually updates when selection changes', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        var radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.system);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        radioGroup = tester.widget<RadioGroup<ThemeMode>>(
          find.byType(RadioGroup<ThemeMode>),
        );
        expect(radioGroup.groupValue, ThemeMode.dark);
      });
    });

    group('persistence', () {
      testWidgets('selection persists to datasource', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(ThemePackage.getTheme(), ThemeMode.light);
      });
    });

    group('null mode handling', () {
      testWidgets('onChanged does nothing when mode is null', (
        tester,
      ) async {
        await pumpSelectorWidget(tester);

        expect(find.text('Current: system'), findsOneWidget);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();

        expect(find.text('Current: light'), findsOneWidget);
      });
    });
  });
}
