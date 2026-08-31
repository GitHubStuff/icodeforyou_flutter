// packages/app_navigation/test/src/chooser/navigation_chooser_test.dart

import 'package:app_navigation/src/chooser/navigation_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeStorageAbstract;

class _MockThemeStorage extends Mock implements ThemeStorageAbstract {}

void main() {
  group('NavigationChooser', () {
    late ThemeStorageAbstract storage;
    late ThemeCubit themeCubit;

    setUp(() {
      storage = _MockThemeStorage();
      themeCubit = ThemeCubit(storage);
    });

    tearDown(() async {
      await themeCubit.close();
    });

    Widget buildSubject({
      required NavigationChooserCallback chooser,
    }) {
      return MaterialApp(
        home: BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: NavigationChooser(
            chooser: chooser,
          ),
        ),
      );
    }

    test('can be instantiated', () {
      expect(
        NavigationChooser(
          chooser: (_) => const SizedBox.shrink(),
        ),
        isNotNull,
      );
    });

    testWidgets(
      'triggers restore on ThemeCubit on build',
      (WidgetTester tester) async {
        when(() => storage.read()).thenAnswer(
          (_) async => ThemeMode.light,
        );

        await tester.pumpWidget(
          buildSubject(
            chooser: (_) => const SizedBox.shrink(),
          ),
        );

        verify(() => storage.read()).called(1);
      },
    );

    testWidgets(
      'renders widget returned by the chooser callback',
      (WidgetTester tester) async {
        const expectedKey = Key('target_widget_key');
        when(() => storage.read()).thenAnswer(
          (_) async => ThemeMode.system,
        );

        await tester.pumpWidget(
          buildSubject(
            chooser: (context) => const SizedBox(
              key: expectedKey,
            ),
          ),
        );

        expect(find.byKey(expectedKey), findsOneWidget);
      },
    );

    testWidgets(
      'passes valid BuildContext down to chooser callback',
      (WidgetTester tester) async {
        BuildContext? capturedContext;
        when(() => storage.read()).thenAnswer(
          (_) async => ThemeMode.dark,
        );

        await tester.pumpWidget(
          buildSubject(
            chooser: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        );

        expect(capturedContext, isNotNull);
        expect(
          capturedContext!.read<ThemeCubit>(),
          equals(themeCubit),
        );
      },
    );
  });
}
