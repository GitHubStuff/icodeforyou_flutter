// packages/theme_framework/test/src/widgets/settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:theme_framework/theme_framework.dart'
    show SettingsScreen, ThemeCubit, ThemeModeCard, ThemeStorageAbstract;

/// A lightweight fake to satisfy the [ThemeCubit] dependency.
class _FakeThemeStorage implements ThemeStorageAbstract {
  ThemeMode? storedMode;

  @override
  Future<ThemeMode?> read() async => storedMode;

  @override
  Future<void> write(ThemeMode mode) async {
    storedMode = mode;
  }
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders default title and provided preferences with gaps', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(
            preferences: [
              Text('Preference 1'),
              Text('Preference 2'),
            ],
          ),
        ),
      );

      // Verify default title
      expect(find.text('Settings'), findsOneWidget);

      // Verify the list items rendered
      expect(find.text('Preference 1'), findsOneWidget);
      expect(find.text('Preference 2'), findsOneWidget);

      // Verify ListView.separated inserted a Gap between the two items
      expect(find.byType(Gap), findsOneWidget);
    });

    testWidgets('renders custom title and actions when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(
            title: 'Custom Title',
            actions: [Icon(Icons.settings)],
            preferences: [],
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    group('withTheme factory', () {
      testWidgets(
        'renders ThemeModeCard first, followed by extra preferences',
        (tester) async {
          final cubit = ThemeCubit(_FakeThemeStorage());

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<ThemeCubit>.value(
                value: cubit,
                child: SettingsScreen.withTheme(
                  preferences: [const Text('Extra Preference')],
                ),
              ),
            ),
          );

          // Verify the theme card is injected
          expect(find.byType(ThemeModeCard), findsOneWidget);

          // Verify the extra preferences are appended
          expect(find.text('Extra Preference'), findsOneWidget);

          // Verify the separator is present between them
          expect(find.byType(Gap), findsOneWidget);
        },
      );

      testWidgets('wires ThemeModeCard to the ambient ThemeCubit', (
        tester,
      ) async {
        final cubit = ThemeCubit(_FakeThemeStorage());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ThemeCubit>.value(
              value: cubit,
              child: SettingsScreen.withTheme(),
            ),
          ),
        );

        final themeCard = tester.widget<ThemeModeCard>(
          find.byType(ThemeModeCard),
        );

        // Verify the initial state is read correctly (seeds at dark mode for splash)
        expect(themeCard.value, ThemeMode.dark);

        // Simulate the card firing its onChanged callback (e.g., user tapped a choice)
        themeCard.onChanged(ThemeMode.light);

        // Verify the callback successfully wrote to the Cubit
        expect(cubit.state, ThemeMode.light);
      });
    });
  });
}
