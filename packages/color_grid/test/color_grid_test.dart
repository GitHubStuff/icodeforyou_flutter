// packages/color_grid/test/color_grid_test.dartpackages/color_grid/test/color_grid_test.dart


import 'package:color_grid/color_grid.dart' show ColorGrid, ColorGridColorTap;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const int _kColorCount = 15;
const double _kCellSize = 70;
const double _kGapWide = 8;
const double _kGapNarrow = 4;
const double _kNarrowSurfaceWidth = 320;

const Color _kBorderColorLight = Color(0xFF6A1B9A);
const Color _kBorderColorDark = Color(0xFFCE93D8);

/// Fifteen distinct, fully opaque ARGB values.
final List<int> _testColors = List<int>.generate(
  _kColorCount,
  (index) => 0xFF000000 | (index + 1) * 0x0F0F0F,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPicker(
    WidgetTester tester, {
    List<int>? colors,
    ColorGridColorTap? onColorTapped,
    VoidCallback? onRefreshRequested,
    HapticIntensity haptics = HapticIntensity.light,
    double? width,
    Brightness brightness = Brightness.light,
  }) async {
    final picker = ColorGrid(
      colors: colors ?? _testColors,
      onColorTapped: onColorTapped ?? (_, _) {},
      onRefreshRequested: onRefreshRequested ?? () {},
      haptics: haptics,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: Center(
            child: width == null
                ? picker
                : SizedBox(width: width, child: picker),
          ),
        ),
      ),
    );
  }

  List<MethodCall> recordHaptics(WidgetTester tester) {
    final log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') log.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return log;
  }

  Finder inPicker(Finder matching) =>
      find.descendant(of: find.byType(ColorGrid), matching: matching);

  group('construction', () {
    test('asserts when fewer than fifteen colors are supplied', () {
      expect(
        () => ColorGrid(
          colors: _testColors.sublist(0, _kColorCount - 1),
          onColorTapped: (_, __) {},
          onRefreshRequested: () {},
        ),
        throwsAssertionError,
      );
    });

    test('asserts when more than fifteen colors are supplied', () {
      expect(
        () => ColorGrid(
          colors: [..._testColors, 0xFFFFFFFF],
          onColorTapped: (_, __) {},
          onRefreshRequested: () {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('layout', () {
    testWidgets('renders fifteen color cells in supplied order', (
      tester,
    ) async {
      await pumpPicker(tester);

      final cells = tester
          .widgetList<ColoredBox>(inPicker(find.byType(ColoredBox)))
          .toList();

      expect(cells, hasLength(_kColorCount));
      for (var index = 0; index < _kColorCount; index++) {
        expect(cells[index].color, Color(_testColors[index]));
      }
    });

    testWidgets('renders the refresh icon as the sixteenth cell', (
      tester,
    ) async {
      await pumpPicker(tester);

      expect(inPicker(find.byIcon(Icons.refresh)), findsOneWidget);
    });

    testWidgets('sizes every cell at 70x70', (tester) async {
      await pumpPicker(tester);

      final cellFinder = inPicker(find.byType(ColoredBox));
      for (var index = 0; index < _kColorCount; index++) {
        expect(
          tester.getSize(cellFinder.at(index)),
          const Size(_kCellSize, _kCellSize),
        );
      }
    });

    testWidgets('uses 8dp spacing and inset when width allows', (
      tester,
    ) async {
      await pumpPicker(tester);

      final column = tester.widget<Column>(inPicker(find.byType(Column)));
      expect(column.spacing, _kGapWide);

      for (final row in tester.widgetList<Row>(inPicker(find.byType(Row)))) {
        expect(row.spacing, _kGapWide);
      }

      final padding = tester.widget<Padding>(
        inPicker(find.byType(Padding)).first,
      );
      expect(padding.padding, const EdgeInsets.all(_kGapWide));
    });

    testWidgets('drops to 4dp spacing and inset when width is tight', (
      tester,
    ) async {
      await pumpPicker(tester, width: _kNarrowSurfaceWidth);

      final column = tester.widget<Column>(inPicker(find.byType(Column)));
      expect(column.spacing, _kGapNarrow);

      for (final row in tester.widgetList<Row>(inPicker(find.byType(Row)))) {
        expect(row.spacing, _kGapNarrow);
      }

      final padding = tester.widget<Padding>(
        inPicker(find.byType(Padding)).first,
      );
      expect(padding.padding, const EdgeInsets.all(_kGapNarrow));
    });
  });

  group('border', () {
    Border borderOf(WidgetTester tester) {
      final box = tester.widget<DecoratedBox>(
        inPicker(find.byType(DecoratedBox)).first,
      );
      return (box.decoration as BoxDecoration).border! as Border;
    }

    testWidgets('is 2dp purple in light mode', (tester) async {
      await pumpPicker(tester);

      final border = borderOf(tester);
      expect(border.top.width, 2);
      expect(border.top.color, _kBorderColorLight);
    });

    testWidgets('is 2dp purple in dark mode', (tester) async {
      await pumpPicker(tester, brightness: Brightness.dark);

      final border = borderOf(tester);
      expect(border.top.width, 2);
      expect(border.top.color, _kBorderColorDark);
    });
  });

  group('taps', () {
    testWidgets('color cells report their index and ARGB value', (
      tester,
    ) async {
      recordHaptics(tester);
      final taps = <(int, int)>[];
      await pumpPicker(
        tester,
        onColorTapped: (index, colorValue) => taps.add((index, colorValue)),
      );

      final cellFinder = inPicker(find.byType(ColoredBox));
      for (var index = 0; index < _kColorCount; index++) {
        await tester.tap(cellFinder.at(index));
      }

      expect(taps, hasLength(_kColorCount));
      for (var index = 0; index < _kColorCount; index++) {
        expect(taps[index], (index, _testColors[index]));
      }
    });

    testWidgets('refresh cell fires the refresh callback only', (
      tester,
    ) async {
      recordHaptics(tester);
      var refreshes = 0;
      var colorTaps = 0;
      await pumpPicker(
        tester,
        onColorTapped: (_, __) => colorTaps++,
        onRefreshRequested: () => refreshes++,
      );

      await tester.tap(inPicker(find.byIcon(Icons.refresh)));

      expect(refreshes, 1);
      expect(colorTaps, 0);
    });
  });

  group('haptics', () {
    testWidgets('fire on color cell taps by default', (tester) async {
      final log = recordHaptics(tester);
      await pumpPicker(tester);

      await tester.tap(inPicker(find.byType(ColoredBox)).first);

      expect(log, hasLength(1));
      expect(log.single.arguments, 'HapticFeedbackType.lightImpact');
    });

    testWidgets('fire on refresh taps by default', (tester) async {
      final log = recordHaptics(tester);
      await pumpPicker(tester);

      await tester.tap(inPicker(find.byIcon(Icons.refresh)));

      expect(log, hasLength(1));
      expect(log.single.arguments, 'HapticFeedbackType.lightImpact');
    });

    testWidgets('respect the configured intensity', (tester) async {
      final log = recordHaptics(tester);
      await pumpPicker(tester, haptics: HapticIntensity.heavy);

      await tester.tap(inPicker(find.byType(ColoredBox)).first);

      expect(log.single.arguments, 'HapticFeedbackType.heavyImpact');
    });

    testWidgets('stay silent when set to none', (tester) async {
      final log = recordHaptics(tester);
      await pumpPicker(tester, haptics: HapticIntensity.none);

      await tester.tap(inPicker(find.byType(ColoredBox)).first);
      await tester.tap(inPicker(find.byIcon(Icons.refresh)));

      expect(log, isEmpty);
    });
  });
}