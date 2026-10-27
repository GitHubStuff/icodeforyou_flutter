// packages/border_caption/test/src/border_caption_test.dart

import 'package:border_caption/src/border_caption.dart';
import 'package:border_caption/src/border_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _label = 'Label';
const _childKey = Key('child');
const _contentKey = Key('content');
const _childWidth = 200.0;
const _childHeight = 100.0;

Widget _child() => Container(
      key: _childKey,
      width: _childWidth,
      height: _childHeight,
      decoration: BoxDecoration(border: Border.all()),
    );

Widget _host(
  Widget subject, {
  TextDirection textDirection = TextDirection.ltr,
  TextScaler? textScaler,
  Color? scaffoldBackgroundColor,
}) =>
    MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: scaffoldBackgroundColor),
      home: Scaffold(
        body: Directionality(
          textDirection: textDirection,
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: textScaler ?? MediaQuery.textScalerOf(context),
              ),
              child: Center(child: subject),
            ),
          ),
        ),
      ),
    );

/// The [Padding] that reserves the overhang around the child.
Padding _childPadding(WidgetTester tester) => tester.widget<Padding>(
      find.ancestor(of: find.byKey(_childKey), matching: find.byType(Padding)).first,
    );

/// The [Padding] inside the label's filled box.
Padding _labelPadding(WidgetTester tester) => tester.widget<Padding>(
      find.ancestor(of: find.text(_label), matching: find.byType(Padding)).first,
    );

Align _labelAlign(WidgetTester tester) => tester.widget<Align>(
      find.ancestor(of: find.text(_label), matching: find.byType(Align)).first,
    );

ColoredBox _labelBox(WidgetTester tester) => tester.widget<ColoredBox>(
      find.ancestor(of: find.text(_label), matching: find.byType(ColoredBox)).first,
    );

PositionedDirectional _positioned(WidgetTester tester) =>
    tester.widget<PositionedDirectional>(find.byType(PositionedDirectional));

Text _labelText(WidgetTester tester) => tester.widget<Text>(find.text(_label));

double _overhang(WidgetTester tester) {
  final textHeight = tester.getSize(find.text(_label)).height;
  final padding = _labelPadding(tester).padding.vertical;
  return (textHeight + padding) / 2;
}

void main() {
  group('BorderCaption', () {
    group('defaults', () {
      test('general constructor', () {
        const subject = BorderCaption(label: _label, child: SizedBox());

        expect(subject.borderPosition, BorderPosition.bottom);
        expect(subject.labelAlignment, AlignmentDirectional.centerEnd);
        expect(subject.labelInset, 16);
        expect(subject.labelStyle, isNull);
        expect(subject.labelPadding, const EdgeInsets.symmetric(horizontal: 4));
        expect(subject.backgroundColor, isNull);
      });

      test('outlined constructor', () {
        final subject = BorderCaption.outlined(
          label: _label,
          child: const SizedBox(),
        );

        expect(subject.borderPosition, BorderPosition.bottom);
        expect(subject.labelAlignment, AlignmentDirectional.centerStart);
        expect(subject.labelInset, 16);
        expect(subject.labelStyle, isNull);
        expect(subject.labelPadding, const EdgeInsets.symmetric(horizontal: 4));
        expect(subject.backgroundColor, isNull);
        expect(subject.child, isA<Container>());
      });
    });

    group('structure', () {
      testWidgets('renders label and child', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        expect(find.text(_label), findsOneWidget);
        expect(find.byKey(_childKey), findsOneWidget);
      });

      testWidgets('stack does not clip', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final stack = tester.widget<Stack>(
          find.descendant(
            of: find.byType(BorderCaption),
            matching: find.byType(Stack),
          ),
        );
        expect(stack.clipBehavior, Clip.none);
      });

      testWidgets('label is single-line and does not wrap', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final text = _labelText(tester);
        expect(text.maxLines, 1);
        expect(text.softWrap, isFalse);
      });

      testWidgets('label is wrapped in an IgnorePointer', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final ignore = tester.widget<IgnorePointer>(
          find
              .ancestor(
                of: find.text(_label),
                matching: find.byType(IgnorePointer),
              )
              .first,
        );
        expect(ignore.ignoring, isTrue);
      });

      testWidgets('label align uses heightFactor 1', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        expect(_labelAlign(tester).heightFactor, 1);
      });
    });

    group('borderPosition', () {
      testWidgets('bottom reserves overhang below the child', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final overhang = _overhang(tester);
        final padding = _childPadding(tester).padding as EdgeInsets;

        expect(padding.top, 0);
        expect(padding.left, 0);
        expect(padding.right, 0);
        expect(padding.bottom, closeTo(overhang, 0.5));
      });

      testWidgets('bottom anchors the label to the bottom edge', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final positioned = _positioned(tester);
        expect(positioned.bottom, 0);
        expect(positioned.top, isNull);
      });

      testWidgets('bottom centres the label on the bottom border', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final childRect = tester.getRect(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));

        expect(labelCenter.dy, closeTo(childRect.bottom, 0.5));
      });

      testWidgets('top reserves overhang above the child', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              borderPosition: BorderPosition.top,
              child: _child(),
            ),
          ),
        );

        final overhang = _overhang(tester);
        final padding = _childPadding(tester).padding as EdgeInsets;

        expect(padding.bottom, 0);
        expect(padding.left, 0);
        expect(padding.right, 0);
        expect(padding.top, closeTo(overhang, 0.5));
      });

      testWidgets('top anchors the label to the top edge', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              borderPosition: BorderPosition.top,
              child: _child(),
            ),
          ),
        );

        final positioned = _positioned(tester);
        expect(positioned.top, 0);
        expect(positioned.bottom, isNull);
      });

      testWidgets('top centres the label on the top border', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              borderPosition: BorderPosition.top,
              child: _child(),
            ),
          ),
        );

        final childRect = tester.getRect(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));

        expect(labelCenter.dy, closeTo(childRect.top, 0.5));
      });
    });

    group('sizing', () {
      testWidgets('is taller than the child by the overhang', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final size = tester.getSize(find.byType(BorderCaption));
        expect(size.width, _childWidth);
        expect(size.height, closeTo(_childHeight + _overhang(tester), 0.5));
      });

      testWidgets('vertical labelPadding grows the overhang', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10,
              ),
              child: _child(),
            ),
          ),
        );

        final size = tester.getSize(find.byType(BorderCaption));
        final textHeight = tester.getSize(find.text(_label)).height;

        expect(_labelPadding(tester).padding.vertical, 20);
        expect(
          size.height,
          closeTo(_childHeight + (textHeight + 20) / 2, 0.5),
        );
      });

      testWidgets('text scaling grows the overhang', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );
        final unscaled = tester.getSize(find.byType(BorderCaption)).height;

        await tester.pumpWidget(
          _host(
            BorderCaption(label: _label, child: _child()),
            textScaler: const TextScaler.linear(2),
          ),
        );
        final scaled = tester.getSize(find.byType(BorderCaption)).height;

        expect(
          scaled - _childHeight,
          closeTo((unscaled - _childHeight) * 2, 1),
        );
      });
    });

    group('labelInset', () {
      testWidgets('default is 16 on both ends', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        final positioned = _positioned(tester);
        expect(positioned.start, 16);
        expect(positioned.end, 16);
      });

      testWidgets('custom inset is applied to both ends', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, labelInset: 40, child: _child())),
        );

        final positioned = _positioned(tester);
        expect(positioned.start, 40);
        expect(positioned.end, 40);
      });

      testWidgets('zero inset lets the label reach the corner', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelInset: 0,
              labelAlignment: AlignmentDirectional.centerStart,
              labelPadding: EdgeInsets.zero,
              child: _child(),
            ),
          ),
        );

        final childRect = tester.getRect(find.byKey(_childKey));
        final labelRect = tester.getRect(find.text(_label));

        expect(labelRect.left, closeTo(childRect.left, 0.5));
      });
    });

    group('labelAlignment', () {
      testWidgets('is forwarded to Align', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.center,
              child: _child(),
            ),
          ),
        );

        expect(_labelAlign(tester).alignment, AlignmentDirectional.center);
      });

      testWidgets('centerStart sits left in LTR', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.centerStart,
              child: _child(),
            ),
          ),
        );

        final childCenter = tester.getCenter(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));
        expect(labelCenter.dx, lessThan(childCenter.dx));
      });

      testWidgets('centerStart sits right in RTL', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.centerStart,
              child: _child(),
            ),
            textDirection: TextDirection.rtl,
          ),
        );

        final childCenter = tester.getCenter(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));
        expect(labelCenter.dx, greaterThan(childCenter.dx));
      });

      testWidgets('centerEnd sits right in LTR', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.centerEnd,
              child: _child(),
            ),
          ),
        );

        final childCenter = tester.getCenter(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));
        expect(labelCenter.dx, greaterThan(childCenter.dx));
      });

      testWidgets('center is horizontally centred', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.center,
              child: _child(),
            ),
          ),
        );

        final childCenter = tester.getCenter(find.byKey(_childKey));
        final labelCenter = tester.getCenter(find.text(_label));
        expect(labelCenter.dx, closeTo(childCenter.dx, 0.5));
      });
    });

    group('labelStyle', () {
      testWidgets('null inherits the ambient DefaultTextStyle', (tester) async {
        late TextStyle ambient;

        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              child: Builder(
                builder: (context) {
                  ambient = DefaultTextStyle.of(context).style;
                  return _child();
                },
              ),
            ),
          ),
        );

        expect(_labelText(tester).style, ambient);
      });

      testWidgets('is merged on top of the ambient style', (tester) async {
        late TextStyle ambient;

        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelStyle: const TextStyle(fontSize: 30, color: Colors.red),
              child: Builder(
                builder: (context) {
                  ambient = DefaultTextStyle.of(context).style;
                  return _child();
                },
              ),
            ),
          ),
        );

        final style = _labelText(tester).style!;
        expect(style.fontSize, 30);
        expect(style.color, Colors.red);
        expect(style.fontFamily, ambient.fontFamily);
        expect(style, ambient.merge(const TextStyle(fontSize: 30, color: Colors.red)));
      });
    });

    group('labelPadding', () {
      testWidgets('default is 4 horizontally', (tester) async {
        await tester.pumpWidget(
          _host(BorderCaption(label: _label, child: _child())),
        );

        expect(
          _labelPadding(tester).padding,
          const EdgeInsets.symmetric(horizontal: 4),
        );
      });

      testWidgets('custom padding surrounds the text', (tester) async {
        const padding = EdgeInsets.fromLTRB(1, 2, 3, 4);

        await tester.pumpWidget(
          _host(
            BorderCaption(label: _label, labelPadding: padding, child: _child()),
          ),
        );

        expect(_labelPadding(tester).padding, padding);

        final boxRect = tester.getRect(
          find
              .ancestor(
                of: find.text(_label),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        final textRect = tester.getRect(find.text(_label));

        expect(textRect.left - boxRect.left, closeTo(1, 0.5));
        expect(textRect.top - boxRect.top, closeTo(2, 0.5));
        expect(boxRect.right - textRect.right, closeTo(3, 0.5));
        expect(boxRect.bottom - textRect.bottom, closeTo(4, 0.5));
      });
    });

    group('backgroundColor', () {
      testWidgets('null falls back to scaffoldBackgroundColor', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(label: _label, child: _child()),
            scaffoldBackgroundColor: Colors.amber,
          ),
        );

        expect(_labelBox(tester).color, Colors.amber);
      });

      testWidgets('explicit colour fills the label box', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              backgroundColor: Colors.teal,
              child: _child(),
            ),
            scaffoldBackgroundColor: Colors.amber,
          ),
        );

        expect(_labelBox(tester).color, Colors.teal);
      });
    });

    group('hit testing', () {
      testWidgets('pointer events over the label reach the child', (tester) async {
        var taps = 0;

        await tester.pumpWidget(
          _host(
            BorderCaption(
              label: _label,
              labelAlignment: AlignmentDirectional.center,
              child: SizedBox(
                key: _childKey,
                width: 300,
                height: _childHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                ),
              ),
            ),
          ),
        );

        // Just inside the child's bottom edge, under the label.
        final point = tester.getCenter(find.text(_label)) - const Offset(0, 2);
        expect(tester.getRect(find.byKey(_childKey)).contains(point), isTrue);
        expect(tester.getRect(find.text(_label)).contains(point), isTrue);

        await tester.tapAt(point);
        await tester.pump();

        expect(taps, 1);
      });
    });

    group('outlined', () {
      testWidgets('renders label and content', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption.outlined(
              label: _label,
              child: const SizedBox(key: _contentKey, width: 100, height: 40),
            ),
          ),
        );

        expect(find.text(_label), findsOneWidget);
        expect(find.byKey(_contentKey), findsOneWidget);
      });

      testWidgets('wraps content in a Container with default outline', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption.outlined(
              label: _label,
              child: const SizedBox(key: _contentKey, width: 100, height: 40),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .ancestor(of: find.byKey(_contentKey), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration! as BoxDecoration;
        final border = decoration.border! as Border;

        expect(container.padding, const EdgeInsets.all(16));
        expect(border.top.color, const Color(0xFF000000));
        expect(border.top.width, 1);
        expect(border.isUniform, isTrue);
        expect(
          decoration.borderRadius,
          const BorderRadius.all(Radius.circular(8)),
        );
      });

      testWidgets('custom outline parameters are applied', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption.outlined(
              label: _label,
              borderColor: Colors.blue,
              borderWidth: 3,
              borderRadius: BorderRadius.zero,
              padding: const EdgeInsets.all(2),
              child: const SizedBox(key: _contentKey, width: 100, height: 40),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .ancestor(of: find.byKey(_contentKey), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration! as BoxDecoration;
        final border = decoration.border! as Border;

        expect(container.padding, const EdgeInsets.all(2));
        expect(border.top.color, Colors.blue);
        expect(border.top.width, 3);
        expect(decoration.borderRadius, BorderRadius.zero);
      });

      testWidgets('outline size is content plus padding plus border', (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption.outlined(
              label: _label,
              borderWidth: 2,
              padding: const EdgeInsets.all(10),
              child: const SizedBox(key: _contentKey, width: 100, height: 40),
            ),
          ),
        );

        final outline = tester.getSize(
          find
              .ancestor(of: find.byKey(_contentKey), matching: find.byType(Container))
              .first,
        );

        expect(outline.width, 100 + 2 * 10 + 2 * 2);
        expect(outline.height, 40 + 2 * 10 + 2 * 2);
      });

      testWidgets('label parameters behave as in the general constructor',
          (tester) async {
        await tester.pumpWidget(
          _host(
            BorderCaption.outlined(
              label: _label,
              borderPosition: BorderPosition.top,
              labelAlignment: AlignmentDirectional.center,
              labelInset: 24,
              labelStyle: const TextStyle(fontSize: 22),
              labelPadding: const EdgeInsets.all(6),
              backgroundColor: Colors.lime,
              child: const SizedBox(key: _contentKey, width: 100, height: 40),
            ),
          ),
        );

        final positioned = _positioned(tester);
        expect(positioned.top, 0);
        expect(positioned.bottom, isNull);
        expect(positioned.start, 24);
        expect(positioned.end, 24);
        expect(_labelAlign(tester).alignment, AlignmentDirectional.center);
        expect(_labelText(tester).style!.fontSize, 22);
        expect(_labelPadding(tester).padding, const EdgeInsets.all(6));
        expect(_labelBox(tester).color, Colors.lime);
      });
    });
  });
}
