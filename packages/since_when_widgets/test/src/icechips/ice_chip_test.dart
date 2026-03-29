// since_when_widgets/test/src/icechips/ice_chip_test.dart

import 'package:extensions/extensions.dart' show ColorExtension;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/since_when.dart' show RecordTagDefinition;
import 'package:since_when_widgets/since_when_widgets.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RecordTagDefinition _tag({
  String name = 'Work',
  int color = 0xFF2196F3,
}) => RecordTagDefinition(tagName: name, color: color, createdTimeStamp: 0);

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('IceChip default constructor', () {
    testWidgets('renders without error using defaults', (tester) async {
      await tester.pumpWidget(_wrap(IceChip(tagRecord: _tag())));
      expect(find.byType(IceChip), findsOneWidget);
    });

    testWidgets('exposes the supplied tagRecord', (tester) async {
      final tag = _tag(name: 'Alpha');
      await tester.pumpWidget(_wrap(IceChip(tagRecord: tag)));
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.tagRecord, tag);
    });

    testWidgets('exposes custom style', (tester) async {
      const style = TextStyle(fontSize: 18);
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), style: style)),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.style.fontSize, 18);
    });

    testWidgets('exposes custom borderWidth', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), borderWidth: 2)),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.borderWidth, 2.0);
    });

    testWidgets('exposes custom padding', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), padding: IceChipPadding.loose)),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.padding, IceChipPadding.loose);
    });

    testWidgets('exposes custom maxCharacters', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), maxCharacters: 4)),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.maxCharacters, 4);
    });

    test('assert fires for negative borderWidth', () {
      expect(
        () => IceChip(tagRecord: _tag(), borderWidth: -0.1),
        throwsAssertionError,
      );
    });

    test('assert fires when maxCharacters is zero', () {
      expect(
        () => IceChip(tagRecord: _tag(), maxCharacters: 0),
        throwsAssertionError,
      );
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip.standard factory', () {
    testWidgets('renders with defaults', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip.standard(_tag())),
      );
      expect(find.byType(IceChip), findsOneWidget);
    });

    testWidgets('accepts custom borderWidth and padding', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IceChip.standard(
            _tag(),
            borderWidth: 1.5,
            padding: IceChipPadding.tight,
          ),
        ),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.borderWidth, 1.5);
      expect(widget.padding, IceChipPadding.tight);
    });

    test('throws ArgumentError for negative borderWidth', () {
      expect(
        () => IceChip.standard(_tag(), borderWidth: -1),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip.expanded factory', () {
    testWidgets('renders without constraints', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip.expanded(_tag())),
      );
      expect(find.byType(IceChip), findsOneWidget);
    });

    testWidgets('renders with explicit BoxConstraints', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IceChip.expanded(
            _tag(name: 'Hello'),
            constraints: const BoxConstraints(maxWidth: 120),
          ),
        ),
      );
      expect(find.byType(IceChip), findsOneWidget);
    });

    testWidgets('accepts custom fontWeight, padding, and borderWidth', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          IceChip.expanded(
            _tag(),
            fontWeight: FontWeight.w300,
            padding: IceChipPadding.loose,
            borderWidth: 1,
          ),
        ),
      );
      final widget = tester.widget<IceChip>(find.byType(IceChip));
      expect(widget.padding, IceChipPadding.loose);
      expect(widget.borderWidth, 1.0);
    });

    test('throws ArgumentError for negative borderWidth', () {
      expect(
        () => IceChip.expanded(_tag(), borderWidth: -0.5),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when minFontSize is zero', () {
      expect(
        () => IceChip.expanded(_tag(), minFontSize: 0),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when minFontSize is negative', () {
      expect(
        () => IceChip.expanded(_tag(), minFontSize: -1),
        throwsArgumentError,
      );
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip build — label display', () {
    testWidgets('shows full name when within maxCharacters', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(name: 'Work'), maxCharacters: 7)),
      );
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets(
      'truncates and appends ellipsis when name exceeds maxCharacters',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            IceChip(tagRecord: _tag(name: 'Groceries'), maxCharacters: 5),
          ),
        );
        // 'Groc…' — first 4 chars + ellipsis
        expect(find.text('Groc…'), findsOneWidget);
      },
    );

    testWidgets('name exactly equal to maxCharacters is not truncated', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          IceChip(tagRecord: _tag(name: 'Hello'), maxCharacters: 5),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip build — background', () {
    testWidgets('DecoratedBox for background is present', (tester) async {
      await tester.pumpWidget(_wrap(IceChip(tagRecord: _tag())));
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip build — border', () {
    testWidgets('no border DecoratedBox when borderWidth is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), borderWidth: 0)),
      );
      // Only the background DecoratedBox; no border overlay
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final borderBoxes = boxes.where((b) {
        final deco = b.decoration;
        if (deco is ShapeDecoration) {
          final shape = deco.shape;
          if (shape is StadiumBorder) {
            return shape.side.width > 0;
          }
        }
        return false;
      });
      expect(borderBoxes, isEmpty);
    });

    testWidgets('border DecoratedBox present when borderWidth > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(), borderWidth: 2)),
      );
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final borderBoxes = boxes.where((b) {
        final deco = b.decoration;
        if (deco is ShapeDecoration) {
          final shape = deco.shape;
          if (shape is StadiumBorder) {
            return shape.side.width > 0;
          }
        }
        return false;
      });
      expect(borderBoxes, isNotEmpty);
    });

    testWidgets('border color is black in light theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IceChip(tagRecord: _tag(), borderWidth: 1),
          theme: ThemeData(brightness: Brightness.light),
        ),
      );
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final borderBox = boxes.firstWhere((b) {
        final deco = b.decoration;
        if (deco is ShapeDecoration) {
          return deco.shape is StadiumBorder &&
              (deco.shape as StadiumBorder).side.width > 0;
        }
        return false;
      });
      final side =
          ((borderBox.decoration as ShapeDecoration).shape as StadiumBorder)
              .side;
      expect(side.color, const Color(0xFF000000));
    });

    testWidgets('border color is white in dark theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IceChip(tagRecord: _tag(), borderWidth: 1),
          theme: ThemeData(brightness: Brightness.dark),
        ),
      );
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final borderBox = boxes.firstWhere((b) {
        final deco = b.decoration;
        if (deco is ShapeDecoration) {
          return deco.shape is StadiumBorder &&
              (deco.shape as StadiumBorder).side.width > 0;
        }
        return false;
      });
      final side =
          ((borderBox.decoration as ShapeDecoration).shape as StadiumBorder)
              .side;
      expect(side.color, const Color(0xFFFFFFFF));
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip build — text color contrast', () {
    testWidgets('text color is contrasting against tag color', (tester) async {
      // Use a known color so we can predict the contrast result
      const tagColor = 0xFF000000; // black background → white text
      await tester.pumpWidget(
        _wrap(IceChip(tagRecord: _tag(color: tagColor))),
      );
      final text = tester.widget<Text>(find.byType(Text));
      // contrastingTextColor() on black should be white
      expect(text.style?.color, const Color(0xFF000000).contrastingTextColor());
    });
  });

  // -------------------------------------------------------------------------

  group('IceChip build — sizing', () {
    testWidgets('SizedBox wraps the Stack', (tester) async {
      await tester.pumpWidget(_wrap(IceChip(tagRecord: _tag())));
      expect(find.byType(SizedBox), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(IceChip),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });
  });
}
