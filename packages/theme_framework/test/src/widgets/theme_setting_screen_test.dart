// packages/theme_framework/test/src/widgets/theme_setting_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeModeCard, ThemeSettingScreen, ThemeStorageAbstract;

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
  group('ThemeSettingScreen', () {
    testWidgets('renders AppBar with default title and optional actions', (
      tester,
    ) async {
      final cubit = ThemeCubit(_FakeThemeStorage());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ThemeCubit>.value(
            value: cubit,
            child: const ThemeSettingScreen(
              actions: [Icon(Icons.info)],
            ),
          ),
        ),
      );

      // Verify default title is displayed
      expect(find.text('App Settings'), findsOneWidget);

      // Verify the custom action icon is rendered
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Verify the ThemeModeCard is rendered inside the body
      expect(find.byType(ThemeModeCard), findsOneWidget);
    });

    testWidgets('wires ThemeModeCard to read and write from ambient ThemeCubit', (
      tester,
    ) async {
      final cubit = ThemeCubit(_FakeThemeStorage());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ThemeCubit>.value(
            value: cubit,
            child: const ThemeSettingScreen(),
          ),
        ),
      );

      final themeCard = tester.widget<ThemeModeCard>(
        find.byType(ThemeModeCard),
      );

      // Verify the initial state is successfully read from the Cubit
      // (ThemeCubit seeds at ThemeMode.dark for the splash screen phase)
      expect(themeCard.value, ThemeMode.dark);

      // Simulate a user tapping the 'Light' mode option in the UI
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Verify the ThemeModeCard's onChanged callback successfully
      // routed the intent to the Cubit via context.read<ThemeCubit>().setThemeMode
      expect(cubit.state, ThemeMode.light);
    });
  });
}
