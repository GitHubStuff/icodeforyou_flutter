// packages/animated_widgets/test/src/pill_widget/pill_widget_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const smallFontSize = 14.0;
  const mediumFontSize = 16.0;
  const largeFontSize = 18.0;
  const borderWidth = 2.0;
  const placeholder = 'tag';

  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: Center(child: child)),
    );
  }

  FilterChip chipOf(WidgetTester tester) {
    return tester.widget<FilterChip>(find.byType(FilterChip));
  }

  Text labelOf(WidgetTester tester) {
    return tester.widget<Text>(
      find.descendant(of: find.byType(FilterChip), matching: find.byType(Text)),
    );
  }

  group('PillWidget constructors', () {
    testWidgets('default constructor uses font size 14 when unspecified', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'alpha',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.fontSize, smallFontSize);
      expect(labelOf(tester).data, 'alpha');
    });

    testWidgets('default constructor honours an explicit fontSize', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'alpha',
            color: Colors.blue,
            fontSize: 22,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.fontSize, 22);
    });

    testWidgets('small constructor uses font size 14', (tester) async {
      await tester.pumpWidget(
        wrap(
          PillWidget.small(
            label: 'phone',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.fontSize, smallFontSize);
    });

    testWidgets('medium constructor uses font size 16', (tester) async {
      await tester.pumpWidget(
        wrap(
          PillWidget.medium(
            label: 'tablet',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.fontSize, mediumFontSize);
    });

    testWidgets('large constructor uses font size 18', (tester) async {
      await tester.pumpWidget(
        wrap(
          PillWidget.large(
            label: 'desktop',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.fontSize, largeFontSize);
    });
  });

  group('PillWidget selection', () {
    testWidgets('tap selects the pill and reports true', (tester) async {
      final reported = <bool>[];

      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'toggle',
            color: Colors.blue,
            onSelected: reported.add,
          ),
        ),
      );

      expect(chipOf(tester).selected, isFalse);

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      expect(reported, [true]);
      expect(chipOf(tester).selected, isTrue);
    });

    testWidgets('second tap deselects the pill and reports false', (
      tester,
    ) async {
      final reported = <bool>[];

      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'toggle',
            color: Colors.blue,
            onSelected: reported.add,
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      expect(reported, [true, false]);
      expect(chipOf(tester).selected, isFalse);
    });

    testWidgets('initialSelected true starts the pill selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'seeded',
            color: Colors.blue,
            initialSelected: true,
            onSelected: (_) {},
          ),
        ),
      );

      expect(chipOf(tester).selected, isTrue);
    });
  });

  group('PillWidget empty label', () {
    testWidgets('renders the placeholder text on the surface variant colors', (
      tester,
    ) async {
      late ThemeData theme;

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              theme = Theme.of(context);
              return PillWidget(
                label: '',
                color: Colors.blue,
                onSelected: (_) {},
              );
            },
          ),
        ),
      );

      final chip = chipOf(tester);
      final label = labelOf(tester);

      expect(label.data, placeholder);
      expect(label.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(
        chip.backgroundColor,
        theme.colorScheme.surfaceContainerHighest,
      );
      expect(chip.onSelected, isNull);
    });

    testWidgets('tapping the placeholder never invokes onSelected', (
      tester,
    ) async {
      var callCount = 0;

      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: '',
            color: Colors.blue,
            onSelected: (_) => callCount++,
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(chipOf(tester).selected, isFalse);
    });
  });

  group('PillWidget label luminance', () {
    testWidgets('bright background picks liteThemeColor', (tester) async {
      const lite = Color(0xFF112233);
      const dark = Color(0xFFAABBCC);

      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'bright',
            color: Colors.white, // luminance 1.0 > 0.5
            liteThemeColor: lite,
            darkThemeColor: dark,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.color, lite);
      expect(chipOf(tester).backgroundColor, Colors.white);
    });

    testWidgets('dark background picks darkThemeColor', (tester) async {
      const lite = Color(0xFF112233);
      const dark = Color(0xFFAABBCC);

      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'dark',
            color: Colors.black, // luminance 0.0 <= 0.5
            liteThemeColor: lite,
            darkThemeColor: dark,
            onSelected: (_) {},
          ),
        ),
      );

      expect(labelOf(tester).style?.color, dark);
      expect(chipOf(tester).backgroundColor, Colors.black);
    });
  });

  group('PillWidget border', () {
    testWidgets('unselected pill carries a transparent border of full width', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'plain',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      final side = chipOf(tester).side;
      expect(side?.color, Colors.transparent);
      expect(side?.width, borderWidth);
    });

    testWidgets('selected pill draws a black border in light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'lit',
            color: Colors.blue,
            initialSelected: true,
            onSelected: (_) {},
          ),
        ),
      );

      final side = chipOf(tester).side;
      expect(side?.color, Colors.black);
      expect(side?.width, borderWidth);
    });

    testWidgets('selected pill draws a white border in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'dim',
            color: Colors.blue,
            initialSelected: true,
            onSelected: (_) {},
          ),
          brightness: Brightness.dark,
        ),
      );

      final side = chipOf(tester).side;
      expect(side?.color, Colors.white);
      expect(side?.width, borderWidth);
    });

    testWidgets('empty label stays borderless even when initialSelected', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: '',
            color: Colors.blue,
            initialSelected: true,
            onSelected: (_) {},
          ),
        ),
      );

      expect(chipOf(tester).side?.color, Colors.transparent);
    });
  });

  group('PillWidget chip configuration', () {
    testWidgets('chip hides the checkmark, uses a stadium shape, and mirrors '
        'the background across all chip color slots', (tester) async {
      await tester.pumpWidget(
        wrap(
          PillWidget(
            label: 'config',
            color: Colors.blue,
            onSelected: (_) {},
          ),
        ),
      );

      final chip = chipOf(tester);
      expect(chip.showCheckmark, isFalse);
      expect(chip.shape, isA<StadiumBorder>());
      expect(chip.backgroundColor, Colors.blue);
      expect(chip.selectedColor, Colors.blue);
      expect(chip.disabledColor, Colors.blue);
    });
  });
}
