// packages/theme_framework/test/src/theme_mode_entry_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/src/theme_mode_entry.dart';
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeModeCard, ThemeStorageAbstract;

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
  group('ThemeModeEntry', () {
    late _FakeThemeStorage storage;
    late ThemeCubit cubit;

    setUp(() {
      storage = _FakeThemeStorage();
      cubit = ThemeCubit(storage);
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('renders ThemeModeCard and wires it to ThemeCubit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ThemeCubit>.value(
              value: cubit,
              child: const ThemeModeEntry(),
            ),
          ),
        ),
      );

      // Verify the ThemeModeCard is successfully built by the entry
      final themeCardFinder = find.byType(ThemeModeCard);
      expect(themeCardFinder, findsOneWidget);

      // Verify the initial state is passed down correctly
      // (ThemeCubit seeds at ThemeMode.dark for the splash screen phase)
      var themeCard = tester.widget<ThemeModeCard>(themeCardFinder);
      expect(themeCard.value, ThemeMode.dark);

      // Act: Simulate a user tapping the 'Light' tile inside the ThemeModeCard
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Verify the BlocBuilder rebuilds the card with the new state
      themeCard = tester.widget<ThemeModeCard>(themeCardFinder);
      expect(themeCard.value, ThemeMode.light);

      // Verify the onChanged callback successfully routed the intent to the Cubit
      expect(cubit.state, ThemeMode.light);
      expect(storage.storedMode, ThemeMode.light);
    });
  });
}
