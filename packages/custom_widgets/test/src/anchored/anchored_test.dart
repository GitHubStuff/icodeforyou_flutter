// packages/custom_widgets/test/src/anchored/anchored_test.dart

import 'package:custom_widgets/custom_widgets.dart' show Anchored;
import 'package:extensions/enum/src/placement.dart' show Placement;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Key on the positioned child so its geometry can be measured.
const Key _kChildKey = Key('anchored-child');

/// Key on the anchor so its geometry can be measured.
const Key _kAnchorKey = Key('anchored-anchor');

/// Pumps an [Anchored] centred in a directionality-only tree.
Future<void> _pump(
  WidgetTester tester, {
  required Placement atPlacement,
  Offset offset = Offset.zero,
}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Anchored(
          atPlacement: atPlacement,
          offset: offset,
          toAnchor: const SizedBox(key: _kAnchorKey, width: 100, height: 100),
          child: const SizedBox(key: _kChildKey, width: 10, height: 10),
        ),
      ),
    ),
  );
}

void main() {
  group('Anchored', () {
    testWidgets('lays out anchor and child in an unclipped Stack',
        (tester) async {
      await _pump(tester, atPlacement: Placement.center);

      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.clipBehavior, Clip.none);
      expect(find.byKey(_kAnchorKey), findsOneWidget);
      expect(find.byKey(_kChildKey), findsOneWidget);
    });

    testWidgets('aligns the child to atPlacement.toAlignment',
        (tester) async {
      await _pump(tester, atPlacement: Placement.bottom);

      final align = tester.widget<Align>(
        find
            .ancestor(
              of: find.byKey(_kChildKey),
              matching: find.byType(Align),
            )
            .first,
      );
      expect(align.alignment, Placement.bottom.toAlignment);
    });

    testWidgets('center placement centres the child over the anchor',
        (tester) async {
      await _pump(tester, atPlacement: Placement.center);

      expect(
        tester.getCenter(find.byKey(_kChildKey)),
        tester.getCenter(find.byKey(_kAnchorKey)),
      );
    });

    testWidgets('offset nudges the child after alignment', (tester) async {
      await _pump(tester, atPlacement: Placement.center);
      final unnudged = tester.getTopLeft(find.byKey(_kChildKey));

      const nudge = Offset(4, -8);
      await _pump(tester, atPlacement: Placement.center, offset: nudge);
      final nudged = tester.getTopLeft(find.byKey(_kChildKey));

      expect(nudged - unnudged, nudge);
    });
  });
}
