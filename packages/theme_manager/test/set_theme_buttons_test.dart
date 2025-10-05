// set_theme_buttons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';

import 'package:theme_manager/theme_manager.dart';
import 'cubit_mock.dart';

void main() {
  group('SetThemeButtons', () {
    late ThemeCubit<MockNoSqlDB> themeCubit;

    setUp(() async {
      themeCubit = await TestThemeCubitFactory.create();
    });

    tearDown(() {
      themeCubit.close();
    });

    Widget createTestWidget({
      Widget? titleWidget,
      Widget? darkThemeWidget,
      Widget? systemThemeWidget,
      Widget? lightThemeWidget,
      Key? widgetKey,
    }) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: BlocProvider<ThemeCubit>.value(
            value: themeCubit,
            child: SetThemeButtons(
              key: widgetKey,
              titleWidget: titleWidget,
              darkThemeWidget: darkThemeWidget,
              systemThemeWidget: systemThemeWidget,
              lightThemeWidget: lightThemeWidget,
            ),
          ),
        ),
      );
    }

    group('Constructor Coverage', () {
      testWidgets('creates with all default parameters', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('creates with custom title widget', (tester) async {
        const customTitle = Text('Custom Theme Title');

        await tester.pumpWidget(createTestWidget(titleWidget: customTitle));

        expect(find.text('Custom Theme Title'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('creates with custom dark theme widget', (tester) async {
        const customDark = Icon(Icons.dark_mode);

        await tester.pumpWidget(createTestWidget(darkThemeWidget: customDark));

        expect(find.text('Theme'), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('creates with custom system theme widget', (tester) async {
        const customSystem = Icon(Icons.auto_mode);

        await tester.pumpWidget(
          createTestWidget(systemThemeWidget: customSystem),
        );

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.byIcon(Icons.auto_mode), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('creates with custom light theme widget', (tester) async {
        const customLight = Icon(Icons.light_mode);

        await tester.pumpWidget(
          createTestWidget(lightThemeWidget: customLight),
        );

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      });

      testWidgets('creates with all custom widgets', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            titleWidget: const Text('All Custom'),
            darkThemeWidget: const Icon(Icons.dark_mode),
            systemThemeWidget: const Icon(Icons.auto_mode),
            lightThemeWidget: const Icon(Icons.light_mode),
          ),
        );

        expect(find.text('All Custom'), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.byIcon(Icons.auto_mode), findsOneWidget);
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      });

      testWidgets('creates with super.key parameter', (tester) async {
        const testKey = Key('theme_buttons_key');

        await tester.pumpWidget(createTestWidget(widgetKey: testKey));

        expect(find.byKey(testKey), findsOneWidget);
      });

      testWidgets('default title widget has correct style', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final titleText = tester.widget<Text>(find.text('Theme'));
        expect(titleText.style?.fontSize, equals(18));
        expect(titleText.style?.fontWeight, equals(FontWeight.bold));
      });

      testWidgets('creates with null widgets falls back to defaults', (
        tester,
      ) async {
        const widget = SetThemeButtons(
          titleWidget: null,
          darkThemeWidget: null,
          systemThemeWidget: null,
          lightThemeWidget: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ThemeCubit>.value(
              value: themeCubit,
              child: widget,
            ),
          ),
        );

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('creates with mixed custom and default widgets', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            titleWidget: const Text('Mixed Title'),
            darkThemeWidget: const Icon(Icons.dark_mode),
            // systemThemeWidget and lightThemeWidget use defaults
          ),
        );

        expect(find.text('Mixed Title'), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('constructor with super.key syntax', (tester) async {
        const widget = SetThemeButtons();

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ThemeCubit>.value(
              value: themeCubit,
              child: widget,
            ),
          ),
        );

        expect(find.byType(SetThemeButtons), findsOneWidget);
      });
    });

    group('Widget Structure Coverage', () {
      testWidgets('contains BlocBuilder with correct types', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.byType(BlocBuilder<ThemeCubit, ThemeState>),
          findsOneWidget,
        );
      });

      testWidgets('contains Card with correct properties', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder?;

        expect(shape, isNotNull);
        expect(shape!.borderRadius, equals(BorderRadius.circular(10)));
        expect(shape.side, isA<BorderSide>());
      });

      testWidgets('card shape uses theme divider color', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        final context = tester.element(find.byType(Card));

        expect(shape.side.color, equals(Theme.of(context).dividerColor));
      });

      testWidgets('contains Column with correct properties', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final column = tester.widget<Column>(find.byType(Column));

        expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
        expect(column.mainAxisSize, equals(MainAxisSize.min));
        expect(column.children, hasLength(5));
      });

      testWidgets('contains Gap with correct spacing', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final gap = tester.widget<Gap>(find.byType(Gap));
        expect(gap.mainAxisExtent, equals(4));
      });

      testWidgets('contains three RadiobuttonAndLabel widgets', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(RadiobuttonAndLabel<ThemeState>), findsNWidgets(3));
      });

      testWidgets('has padding extension applied correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final paddingWidgets = find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        );

        expect(paddingWidgets, findsWidgets);

        bool foundCorrectPadding = false;
        final allPaddingWidgets = tester.widgetList<Padding>(paddingWidgets);

        for (final padding in allPaddingWidgets) {
          if (padding.padding == const EdgeInsets.all(10)) {
            foundCorrectPadding = true;
            break;
          }
        }

        expect(foundCorrectPadding, isTrue);
      });

      testWidgets('RadiobuttonAndLabel widgets use ListTile', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(ListTile), findsNWidgets(3));
      });

      testWidgets('ListTiles have correct properties', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final listTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();

        for (final listTile in listTiles) {
          expect(listTile.visualDensity, equals(VisualDensity.compact));
          expect(listTile.dense, isTrue);
          expect(listTile.leading, isA<Radio>());
          expect(listTile.title, isA<Widget>());
          expect(listTile.onTap, isNotNull);
        }
      });

      testWidgets('Radio widgets have correct values', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<Radio<ThemeState>>(find.byType(Radio<ThemeState>))
            .toList();

        expect(radioWidgets[0].value, equals(ThemeState.dark));
        expect(radioWidgets[1].value, equals(ThemeState.system));
        expect(radioWidgets[2].value, equals(ThemeState.light));
      });
    });

    group('Radio Button Configuration Coverage', () {
      testWidgets('dark theme radio has correct value and label', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        expect(radioWidgets[0].value, equals(ThemeState.dark));
        expect(radioWidgets[0].label, isA<Text>());
      });

      testWidgets('system theme radio has correct value and label', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        expect(radioWidgets[1].value, equals(ThemeState.system));
        expect(radioWidgets[1].label, isA<Text>());
      });

      testWidgets('light theme radio has correct value and label', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        expect(radioWidgets[2].value, equals(ThemeState.light));
        expect(radioWidgets[2].label, isA<Text>());
      });

      testWidgets('radio button onChanged callbacks are correctly assigned', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        expect(radioWidgets[0].onChanged, isNotNull);
        expect(radioWidgets[1].onChanged, isNotNull);
        expect(radioWidgets[2].onChanged, isNotNull);
      });

      testWidgets('custom widgets are properly passed to radio buttons', (
        tester,
      ) async {
        const customDark = Icon(Icons.dark_mode_outlined);
        const customSystem = Icon(Icons.settings_brightness);
        const customLight = Icon(Icons.light_mode_outlined);

        await tester.pumpWidget(
          createTestWidget(
            darkThemeWidget: customDark,
            systemThemeWidget: customSystem,
            lightThemeWidget: customLight,
          ),
        );

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        expect(radioWidgets[0].label, equals(customDark));
        expect(radioWidgets[1].label, equals(customSystem));
        expect(radioWidgets[2].label, equals(customLight));
      });
    });

    group('User Interaction Coverage', () {
      testWidgets('dark theme ListTile tap calls setTheme with dark mode', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final darkListTile = find.byType(ListTile).first;
        await tester.tap(darkListTile);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeState.dark));
      });

      testWidgets('system theme ListTile tap calls setTheme with system mode', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final systemListTile = find.byType(ListTile).at(1);
        await tester.tap(systemListTile);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeState.system));
      });

      testWidgets('light theme ListTile tap calls setTheme with light mode', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final lightListTile = find.byType(ListTile).at(2);
        await tester.tap(lightListTile);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeState.light));
      });

      testWidgets('dark theme radio direct tap calls setTheme with dark mode', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final darkRadio = find.byType(Radio<ThemeState>).first;
        await tester.tap(darkRadio);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeState.dark));
      });

      testWidgets(
        'system theme radio direct tap calls setTheme with system mode',
        (tester) async {
          await tester.pumpWidget(createTestWidget());

          final systemRadio = find.byType(Radio<ThemeState>).at(1);
          await tester.tap(systemRadio);
          await tester.pumpAndSettle();

          expect(themeCubit.state, equals(ThemeState.system));
        },
      );

      testWidgets(
        'light theme radio direct tap calls setTheme with light mode',
        (tester) async {
          await tester.pumpWidget(createTestWidget());

          final lightRadio = find.byType(Radio<ThemeState>).at(2);
          await tester.tap(lightRadio);
          await tester.pumpAndSettle();

          expect(themeCubit.state, equals(ThemeState.light));
        },
      );

      testWidgets('onChanged with null value does not change theme', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final initialState = themeCubit.state;

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        // Call onChanged with null
        radioWidgets[0].onChanged(null);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(initialState));
      });

      testWidgets('onChanged with non-null value changes theme correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final radioWidgets = tester
            .widgetList<RadiobuttonAndLabel<ThemeState>>(
              find.byType(RadiobuttonAndLabel<ThemeState>),
            )
            .toList();

        radioWidgets[0].onChanged(ThemeState.dark);
        await tester.pumpAndSettle();

        expect(themeCubit.state, equals(ThemeState.dark));
      });

      testWidgets('multiple rapid interactions work correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byType(ListTile).first); // Dark
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.dark));

        await tester.tap(find.byType(ListTile).at(2)); // Light
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.light));

        await tester.tap(find.byType(ListTile).at(1)); // System
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.system));
      });
    });

    group('BlocBuilder State Coverage', () {
      testWidgets('rebuilds when state changes to dark', (tester) async {
        themeCubit.emit(ThemeState.light);
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Theme'), findsOneWidget);

        themeCubit.emit(ThemeState.dark);
        await tester.pump();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
      });

      testWidgets('rebuilds when state changes to light', (tester) async {
        themeCubit.emit(ThemeState.dark);
        await tester.pumpWidget(createTestWidget());

        themeCubit.emit(ThemeState.light);
        await tester.pump();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('rebuilds when state changes to system', (tester) async {
        themeCubit.emit(ThemeState.dark);
        await tester.pumpWidget(createTestWidget());

        themeCubit.emit(ThemeState.system);
        await tester.pump();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
      });

      testWidgets('rebuilds when state changes to initial', (tester) async {
        themeCubit.emit(ThemeState.dark);
        await tester.pumpWidget(createTestWidget());

        themeCubit.emit(ThemeState.initial);
        await tester.pump();

        expect(find.text('Theme'), findsOneWidget);
      });

      testWidgets('builder function receives correct context and state', (
        tester,
      ) async {
        BuildContext? capturedContext;
        ThemeState? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ThemeCubit>.value(
              value: themeCubit,
              child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  capturedContext = context;
                  capturedState = state;
                  return const SetThemeButtons();
                },
              ),
            ),
          ),
        );

        expect(capturedContext, isNotNull);
        expect(capturedState, equals(ThemeState.system));
      });

      testWidgets('context.read returns correct cubit instance', (
        tester,
      ) async {
        ThemeCubit? capturedCubit;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ThemeCubit>.value(
              value: themeCubit,
              child: Builder(
                builder: (context) {
                  capturedCubit = context.read<ThemeCubit>();
                  return const SetThemeButtons();
                },
              ),
            ),
          ),
        );

        expect(capturedCubit, equals(themeCubit));
      });

      testWidgets('handles all ThemeState enum values', (tester) async {
        for (final state in ThemeState.values) {
          themeCubit.emit(state);
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.text('Theme'), findsOneWidget);
          expect(find.text('Dark'), findsOneWidget);
          expect(find.text('System'), findsOneWidget);
          expect(find.text('Light'), findsOneWidget);
        }
      });
    });

    group('Edge Cases Coverage', () {
      testWidgets('handles rapid state changes correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        themeCubit.setTheme(ThemeMode.dark);
        await tester.pump();

        themeCubit.setTheme(ThemeMode.light);
        await tester.pump();

        themeCubit.setTheme(ThemeMode.system);
        await tester.pump();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(themeCubit.state, equals(ThemeState.system));
      });

      testWidgets('works with different theme data', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: BlocProvider<ThemeCubit>.value(
                value: themeCubit,
                child: const SetThemeButtons(),
              ),
            ),
          ),
        );

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
      });

      testWidgets('maintains widget hierarchy under different parent widgets', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: BlocProvider<ThemeCubit>.value(
                    value: themeCubit,
                    child: const SetThemeButtons(),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(SetThemeButtons), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('extension method withPaddingAll works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final paddingWidgets = find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        );

        expect(paddingWidgets, findsWidgets);

        bool foundCorrectPadding = false;
        final allPaddingWidgets = tester.widgetList<Padding>(paddingWidgets);

        for (final padding in allPaddingWidgets) {
          if (padding.padding == const EdgeInsets.all(10)) {
            foundCorrectPadding = true;

            final columnInPadding = find.descendant(
              of: find.byWidget(padding),
              matching: find.byType(Column),
            );
            expect(columnInPadding, findsOneWidget);
            break;
          }
        }

        expect(foundCorrectPadding, isTrue);
      });

      testWidgets('handles theme mode conversion correctly in interactions', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Test each theme conversion
        await tester.tap(find.byType(ListTile).first); // Dark
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.dark));

        await tester.tap(find.byType(ListTile).at(1)); // System
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.system));

        await tester.tap(find.byType(ListTile).at(2)); // Light
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.light));
      });

      testWidgets('RadiobuttonAndLabel onTap implementation works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // The RadiobuttonAndLabel should have onTap that calls onChanged with its value
        final listTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();

        expect(listTiles[0].onTap, isNotNull);
        expect(listTiles[1].onTap, isNotNull);
        expect(listTiles[2].onTap, isNotNull);

        // Verify the onTap functionality through direct calls
        listTiles[0].onTap!();
        await tester.pump();
        expect(themeCubit.state, equals(ThemeState.dark));
      });
    });
  });
}
