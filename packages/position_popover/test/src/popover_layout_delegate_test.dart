// packages/position_popover/test/src/popover_layout_delegate_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:position_popover/src/popover_layout_delegate.dart' show PopoverLayoutDelegate;

void main() {
  const area = Size(400, 800);
  const anchor = Rect.fromLTWH(100, 200, 120, 40);
  const childSize = Size(200, 100);

  PopoverLayoutDelegate delegate(Alignment alignment) {
    return PopoverLayoutDelegate(anchor: anchor, alignment: alignment);
  }

  group('PopoverLayoutDelegate', () {
    group('getConstraintsForChild', () {
      test('loosens the incoming constraints', () {
        const tight = BoxConstraints.tightFor(width: 400, height: 800);

        final result = delegate(Alignment.center).getConstraintsForChild(
          tight,
        );

        expect(result, tight.loosen());
        expect(result.minWidth, 0);
        expect(result.minHeight, 0);
        expect(result.maxWidth, 400);
        expect(result.maxHeight, 800);
      });
    });

    group('getPositionForChild', () {
      test('centres the child over the anchor for Alignment.center', () {
        final origin = delegate(Alignment.center).getPositionForChild(
          area,
          childSize,
        );

        expect(origin, const Offset(60, 170));
      });

      test('places the child above the anchor for Alignment.topCenter', () {
        final origin = delegate(Alignment.topCenter).getPositionForChild(
          area,
          childSize,
        );

        expect(origin, const Offset(60, 100));
      });

      test('hangs the child below-right for Alignment.bottomRight', () {
        const narrowChild = Size(150, 100);

        final origin = delegate(Alignment.bottomRight).getPositionForChild(
          area,
          narrowChild,
        );

        expect(origin, const Offset(220, 240));
      });

      test('clamps a child that would overflow the right edge', () {
        const edgeAnchor = Rect.fromLTWH(350, 200, 40, 40);
        const delegate = PopoverLayoutDelegate(
          anchor: edgeAnchor,
          alignment: Alignment.bottomRight,
        );

        final origin = delegate.getPositionForChild(area, childSize);

        expect(origin, const Offset(200, 240));
      });

      test('clamps a child that would overflow the bottom edge', () {
        const edgeAnchor = Rect.fromLTWH(100, 750, 40, 40);
        const delegate = PopoverLayoutDelegate(
          anchor: edgeAnchor,
          alignment: Alignment.bottomCenter,
        );

        final origin = delegate.getPositionForChild(area, childSize);

        expect(origin, const Offset(20, 700));
      });

      test('clamps only the overflowing axis at the left edge', () {
        const edgeAnchor = Rect.fromLTWH(0, 200, 40, 40);
        const delegate = PopoverLayoutDelegate(
          anchor: edgeAnchor,
          alignment: Alignment.topLeft,
        );

        final origin = delegate.getPositionForChild(area, childSize);

        expect(origin, const Offset(0, 100));
      });

      test('pins to zero when the child is larger than the area', () {
        const oversized = Size(500, 900);

        final origin = delegate(Alignment.bottomRight).getPositionForChild(
          area,
          oversized,
        );

        expect(origin, Offset.zero);
      });
    });

    group('shouldRelayout', () {
      test('returns false when anchor and alignment are unchanged', () {
        final a = delegate(Alignment.center);
        final b = delegate(Alignment.center);

        expect(a.shouldRelayout(b), isFalse);
      });

      test('returns true when the alignment changed', () {
        final a = delegate(Alignment.center);
        final b = delegate(Alignment.topLeft);

        expect(a.shouldRelayout(b), isTrue);
      });

      test('returns true when the anchor changed', () {
        const moved = Rect.fromLTWH(0, 0, 120, 40);
        final a = delegate(Alignment.center);
        const b = PopoverLayoutDelegate(
          anchor: moved,
          alignment: Alignment.center,
        );

        expect(a.shouldRelayout(b), isTrue);
      });
    });

    testWidgets('lays out a real child at the computed origin', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(area);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const childKey = Key('child');

      await tester.pumpWidget(
        MaterialApp(
          home: CustomSingleChildLayout(
            delegate: delegate(Alignment.center),
            child: const SizedBox(
              key: childKey,
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(childKey)), const Offset(60, 170));
    });
  });
}
