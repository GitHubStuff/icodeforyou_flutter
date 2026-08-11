// packages/ice_chips/test/src/ice_chip_widget/ice_chip_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/ice_chip_widget/ice_chip.dart' show IceChip;

/// Opaque red used as the packed background color under test.
const _kColorInt = 0xFFFF0000;

/// Pumps an [IceChip] under a [MaterialApp] with the given [brightness].
Future<void> _pumpChip(
  WidgetTester tester, {
  required bool showBorder,
  required VoidCallback onPress,
  Brightness brightness = Brightness.light,
  TextStyle? style,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: IceChip(
          'CHIP',
          backgroundColorInt: _kColorInt,
          showBorder: showBorder,
          onPress: onPress,
          style: style,
        ),
      ),
    ),
  );
}

/// Reads the rendered [FilterChip] out of the tree.
FilterChip _filterChip(WidgetTester tester) =>
    tester.widget<FilterChip>(find.byType(FilterChip));

void main() {
  group('IceChip', () {
    testWidgets('renders a FilterChip with the message and background',
        (tester) async {
      await _pumpChip(tester, showBorder: false, onPress: () {});

      final chip = _filterChip(tester);
      expect(find.text('CHIP'), findsOneWidget);
      expect(chip.backgroundColor, const Color(_kColorInt));
      expect(chip.selectedColor, const Color(_kColorInt));
      expect(chip.selected, isFalse);
      expect(chip.showCheckmark, isFalse);
      expect(chip.shape, isA<StadiumBorder>());
    });

    testWidgets('tapping the chip invokes onPress', (tester) async {
      var pressed = 0;
      await _pumpChip(tester, showBorder: false, onPress: () => pressed++);

      await tester.tap(find.byType(FilterChip));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('hidden border renders transparent', (tester) async {
      await _pumpChip(tester, showBorder: false, onPress: () {});

      expect(_filterChip(tester).side?.color, Colors.transparent);
    });

    testWidgets('shown border is black in light themes', (tester) async {
      await _pumpChip(tester, showBorder: true, onPress: () {});

      expect(_filterChip(tester).side?.color, Colors.black);
    });

    testWidgets('shown border is white in dark themes', (tester) async {
      await _pumpChip(
        tester,
        showBorder: true,
        onPress: () {},
        brightness: Brightness.dark,
      );

      expect(_filterChip(tester).side?.color, Colors.white);
    });

    testWidgets('caller style merges over the computed label style',
        (tester) async {
      const style = TextStyle(fontSize: 30, fontStyle: FontStyle.italic);
      await _pumpChip(
        tester,
        showBorder: false,
        onPress: () {},
        style: style,
      );

      final labelStyle = _filterChip(tester).labelStyle;
      expect(labelStyle?.fontSize, 30);
      expect(labelStyle?.fontStyle, FontStyle.italic);
      expect(labelStyle?.fontWeight, FontWeight.bold);
    });
  });
}
