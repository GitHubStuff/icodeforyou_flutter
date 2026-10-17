// packages/border_caption/test/border_caption_test.dart
import 'package:border_caption/border_caption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _label = 'some text';
const _content = 'Some static stuff';

Widget _buildBorderedChild() => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(border: Border.all()),
  child: const Text(_content),
);

Future<void> _pump(
  WidgetTester tester,
  Widget subject, {
  TextDirection textDirection = TextDirection.ltr,
  ThemeData? theme,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: textDirection,
        child: Center(child: subject),
      ),
    ),
  );
}

Finder _overhangPadding() => find
    .descendant(of: find.byType(Stack), matching: find.byType(Padding))
    .first;

Finder _labelColoredBox() => find
    .ancestor(of: find.text(_label), matching: find.byType(ColoredBox))
    .first;

Finder _labelPadding() => find
    .descendant(of: _labelColoredBox(), matching: find.byType(Padding))
    .first;

double _expectedOverhang(WidgetTester tester, EdgeInsets labelPadding) {
  final textHeight = tester.getSize(find.text(_label)).height;
  return (textHeight + labelPadding.vertical) / 2;
}

void main() {
  group('LabelBorder', () {
    test('exposes top and bottom', () {
      expect(LabelBorder.values, [LabelBorder.top, LabelBorder.bottom]);
    });
  });

  group('BorderCaption', () {
    testWidgets('renders label and child', (tester) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      expect(find.text(_label), findsOneWidget);
      expect(find.text(_content), findsOneWidget);
    });

    testWidgets('applies default parameters', (tester) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      final subject = tester.widget<BorderCaption>(find.byType(BorderCaption));
      expect(subject.labelBorder, LabelBorder.bottom);
      expect(subject.labelAlignment, AlignmentDirectional.centerEnd);
      expect(subject.labelInset, 16);
      expect(subject.labelStyle, isNull);
      expect(subject.labelPadding, const EdgeInsets.symmetric(horizontal: 4));
      expect(subject.backgroundColor, isNull);
    });

    testWidgets('reserves overhang below the child for a bottom label', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      final overhang = _expectedOverhang(
        tester,
        const EdgeInsets.symmetric(horizontal: 4),
      );
      final padding = tester.widget<Padding>(_overhangPadding());
      expect(padding.padding, EdgeInsets.only(bottom: overhang));

      final positioned = tester.widget<PositionedDirectional>(
        find.byType(PositionedDirectional),
      );
      expect(positioned.top, isNull);
      expect(positioned.bottom, 0);
      expect(positioned.start, 16);
      expect(positioned.end, 16);
    });

    testWidgets('reserves overhang above the child for a top label', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelBorder: LabelBorder.top,
          child: _buildBorderedChild(),
        ),
      );

      final overhang = _expectedOverhang(
        tester,
        const EdgeInsets.symmetric(horizontal: 4),
      );
      final padding = tester.widget<Padding>(_overhangPadding());
      expect(padding.padding, EdgeInsets.only(top: overhang));

      final positioned = tester.widget<PositionedDirectional>(
        find.byType(PositionedDirectional),
      );
      expect(positioned.top, 0);
      expect(positioned.bottom, isNull);
    });

    testWidgets('grows the overhang with vertical label padding', (
      tester,
    ) async {
      const labelPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 6);
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelPadding: labelPadding,
          child: _buildBorderedChild(),
        ),
      );

      final overhang = _expectedOverhang(tester, labelPadding);
      final padding = tester.widget<Padding>(_overhangPadding());
      expect(padding.padding, EdgeInsets.only(bottom: overhang));

      final inner = tester.widget<Padding>(_labelPadding());
      expect(inner.padding, labelPadding);
    });

    testWidgets('is taller than its child by exactly the overhang', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      final overhang = _expectedOverhang(
        tester,
        const EdgeInsets.symmetric(horizontal: 4),
      );
      final stackHeight = tester.getSize(find.byType(BorderCaption)).height;
      final childHeight = tester.getSize(find.byType(Container)).height;
      expect(stackHeight, moreOrLessEquals(childHeight + overhang));
    });

    testWidgets('centres the label vertically on the bottom border', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      final childBottom = tester.getRect(find.byType(Container)).bottom;
      final labelCenterY = tester.getRect(_labelColoredBox()).center.dy;
      expect(labelCenterY, moreOrLessEquals(childBottom));
    });

    testWidgets('centres the label vertically on the top border', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelBorder: LabelBorder.top,
          child: _buildBorderedChild(),
        ),
      );

      final childTop = tester.getRect(find.byType(Container)).top;
      final labelCenterY = tester.getRect(_labelColoredBox()).center.dy;
      expect(labelCenterY, moreOrLessEquals(childTop));
    });

    testWidgets('fills the label box with scaffoldBackgroundColor by default', (
      tester,
    ) async {
      const scaffoldColor = Color(0xFF123456);
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
        theme: ThemeData(scaffoldBackgroundColor: scaffoldColor),
      );

      final box = tester.widget<ColoredBox>(_labelColoredBox());
      expect(box.color, scaffoldColor);
    });

    testWidgets('fills the label box with an explicit backgroundColor', (
      tester,
    ) async {
      const fill = Color(0xFFABCDEF);
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          backgroundColor: fill,
          child: _buildBorderedChild(),
        ),
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF000000)),
      );

      final box = tester.widget<ColoredBox>(_labelColoredBox());
      expect(box.color, fill);
    });

    testWidgets('merges labelStyle on top of the ambient DefaultTextStyle', (
      tester,
    ) async {
      const ambient = TextStyle(fontSize: 20, color: Color(0xFF00FF00));
      const override = TextStyle(fontWeight: FontWeight.bold);
      await _pump(
        tester,
        DefaultTextStyle(
          style: ambient,
          child: BorderCaption(
            label: _label,
            labelStyle: override,
            child: _buildBorderedChild(),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(_label));
      expect(text.style, ambient.merge(override));
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
    });

    testWidgets(
      'inherits the ambient DefaultTextStyle when labelStyle is null',
      (
        tester,
      ) async {
        const ambient = TextStyle(fontSize: 20, color: Color(0xFF00FF00));
        await _pump(
          tester,
          DefaultTextStyle(
            style: ambient,
            child: BorderCaption(label: _label, child: _buildBorderedChild()),
          ),
        );

        final text = tester.widget<Text>(find.text(_label));
        expect(text.style, ambient);
      },
    );

    testWidgets('passes labelAlignment to Align', (tester) async {
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelAlignment: AlignmentDirectional.center,
          child: _buildBorderedChild(),
        ),
      );

      final align = tester.widget<Align>(
        find
            .ancestor(of: find.text(_label), matching: find.byType(Align))
            .first,
      );
      expect(align.alignment, AlignmentDirectional.center);
      expect(align.heightFactor, 1);
    });

    testWidgets('keeps the label clear of the trailing corner in LTR', (
      tester,
    ) async {
      const inset = 24.0;
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelInset: inset,
          child: _buildBorderedChild(),
        ),
      );

      final childRect = tester.getRect(find.byType(Container));
      final labelRect = tester.getRect(_labelColoredBox());
      expect(labelRect.right, moreOrLessEquals(childRect.right - inset));
    });

    testWidgets('resolves centerEnd to the left-hand side in RTL', (
      tester,
    ) async {
      const inset = 24.0;
      await _pump(
        tester,
        BorderCaption(
          label: _label,
          labelInset: inset,
          child: _buildBorderedChild(),
        ),
        textDirection: TextDirection.rtl,
      );

      final childRect = tester.getRect(find.byType(Container));
      final labelRect = tester.getRect(_labelColoredBox());
      expect(labelRect.left, moreOrLessEquals(childRect.left + inset));
    });

    testWidgets('does not clip the overhang inside a tight parent', (
      tester,
    ) async {
      await _pump(
        tester,
        BorderCaption(label: _label, child: _buildBorderedChild()),
      );

      final stack = tester.widget<Stack>(find.byType(Stack).first);
      expect(stack.clipBehavior, Clip.none);
    });
  });

  group('BorderCaption.outlined', () {
    testWidgets('draws a default outline around the content', (tester) async {
      await _pump(
        tester,
        BorderCaption.outlined(label: _label, child: const Text(_content)),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(16));

      final decoration = container.decoration! as BoxDecoration;
      expect(
        decoration.border,
        Border.all(color: const Color(0xFF000000), width: 1),
      );
      expect(decoration.borderRadius, BorderRadius.circular(8));

      expect(find.text(_content), findsOneWidget);
      expect(find.text(_label), findsOneWidget);
    });

    testWidgets('applies default label parameters', (tester) async {
      await _pump(
        tester,
        BorderCaption.outlined(label: _label, child: const Text(_content)),
      );

      final subject = tester.widget<BorderCaption>(find.byType(BorderCaption));
      expect(subject.labelBorder, LabelBorder.bottom);
      expect(subject.labelAlignment, AlignmentDirectional.centerStart);
      expect(subject.labelInset, 16);
      expect(subject.labelStyle, isNull);
      expect(subject.labelPadding, const EdgeInsets.symmetric(horizontal: 4));
      expect(subject.backgroundColor, isNull);
    });

    testWidgets('honours custom border and label parameters', (tester) async {
      const borderColor = Color(0xFFFF0000);
      const borderRadius = BorderRadius.all(Radius.circular(2));
      const padding = EdgeInsets.all(8);
      const labelPadding = EdgeInsets.symmetric(horizontal: 2, vertical: 1);
      const labelStyle = TextStyle(fontStyle: FontStyle.italic);
      const fill = Color(0xFF0000FF);

      await _pump(
        tester,
        BorderCaption.outlined(
          label: _label,
          labelBorder: LabelBorder.top,
          labelAlignment: AlignmentDirectional.centerEnd,
          labelInset: 32,
          labelStyle: labelStyle,
          labelPadding: labelPadding,
          backgroundColor: fill,
          borderColor: borderColor,
          borderWidth: 3,
          borderRadius: borderRadius,
          padding: padding,
          child: const Text(_content),
        ),
      );

      final subject = tester.widget<BorderCaption>(find.byType(BorderCaption));
      expect(subject.labelBorder, LabelBorder.top);
      expect(subject.labelAlignment, AlignmentDirectional.centerEnd);
      expect(subject.labelInset, 32);
      expect(subject.labelStyle, labelStyle);
      expect(subject.labelPadding, labelPadding);
      expect(subject.backgroundColor, fill);

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, padding);

      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border, Border.all(color: borderColor, width: 3));
      expect(decoration.borderRadius, borderRadius);

      final box = tester.widget<ColoredBox>(_labelColoredBox());
      expect(box.color, fill);
    });
  });
}
