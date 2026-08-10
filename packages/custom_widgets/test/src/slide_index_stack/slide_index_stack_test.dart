// packages/custom_widgets/test/src/slide_index_stack/slide_index_stack_test.dart

import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A short slide so tests settle quickly.
const Duration _kDuration = Duration(milliseconds: 200);

/// Keys for the three children under test.
const List<Key> _kKeys = [Key('child-0'), Key('child-1'), Key('child-2')];

/// Pumps a three-child [SlideIndexedStack] showing [index].
Future<void> _pump(
  WidgetTester tester, {
  required int index,
  Axis direction = Axis.horizontal,
  Duration duration = _kDuration,
}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 300,
        height: 300,
        child: SlideIndexedStack(
          index: index,
          direction: direction,
          duration: duration,
          children: [for (final key in _kKeys) SizedBox(key: key)],
        ),
      ),
    ),
  );
}

/// The [SlideTransition] wrapping the child at [index], if any.
Finder _transitionOf(int index) => find.ancestor(
  of: find.byKey(_kKeys[index]),
  matching: find.byType(SlideTransition),
);

/// Finds every [SlideTransition], including any hidden inside an
/// [Offstage] subtree, so "no transitions" assertions are honest.
Finder _allTransitions() => find.byType(SlideTransition, skipOffstage: false);

/// The [Offstage] wrapping the child at [index].
///
/// Offstage subtrees are invisible to default finders, so both the
/// anchor and the ancestor lookup must opt out of offstage skipping.
Offstage _offstageOf(WidgetTester tester, int index) {
  return tester.widget<Offstage>(
    find.ancestor(
      of: find.byKey(_kKeys[index], skipOffstage: false),
      matching: find.byType(Offstage, skipOffstage: false),
    ),
  );
}

/// The [TickerMode] wrapping the child at [index].
TickerMode _tickerModeOf(WidgetTester tester, int index) {
  return tester.widget<TickerMode>(
    find.ancestor(
      of: find.byKey(_kKeys[index], skipOffstage: false),
      matching: find.byType(TickerMode, skipOffstage: false),
    ),
  );
}

/// The incoming slide offset of the child at [index] on the first frame.
Offset _entryOffset(WidgetTester tester, int index) {
  return tester.widget<SlideTransition>(_transitionOf(index)).position.value;
}

void main() {
  group('SlideIndexedStack', () {
    testWidgets('at rest, the selected child is bare and the rest are '
        'offstage with tickers disabled', (tester) async {
      await _pump(tester, index: 0);

      expect(_allTransitions(), findsNothing);
      expect(find.byKey(_kKeys[0]), findsOneWidget);
      for (final hidden in const [1, 2]) {
        expect(_offstageOf(tester, hidden).offstage, isTrue);
        expect(_tickerModeOf(tester, hidden).enabled, isFalse);
      }
    });

    testWidgets('moving to a higher index slides in from the end', (
      tester,
    ) async {
      await _pump(tester, index: 0);
      await _pump(tester, index: 1);

      expect(_entryOffset(tester, 1), const Offset(1, 0));
      expect(_transitionOf(0), findsOneWidget);
      expect(_offstageOf(tester, 2).offstage, isTrue);
    });

    testWidgets('moving to a lower index slides in from the start', (
      tester,
    ) async {
      await _pump(tester, index: 1);
      await _pump(tester, index: 0);

      expect(_entryOffset(tester, 0), const Offset(-1, 0));
      expect(_transitionOf(1), findsOneWidget);
    });

    testWidgets('vertical direction slides along the y axis, both ways', (
      tester,
    ) async {
      await _pump(tester, index: 0, direction: Axis.vertical);
      await _pump(tester, index: 1, direction: Axis.vertical);
      expect(_entryOffset(tester, 1), const Offset(0, 1));

      await tester.pumpAndSettle();

      await _pump(tester, index: 0, direction: Axis.vertical);
      expect(_entryOffset(tester, 0), const Offset(0, -1));
    });

    testWidgets('the slide settles back to the at-rest configuration', (
      tester,
    ) async {
      await _pump(tester, index: 0);
      await _pump(tester, index: 1);
      await tester.pumpAndSettle();

      expect(_allTransitions(), findsNothing);
      expect(_offstageOf(tester, 0).offstage, isTrue);
      expect(_offstageOf(tester, 2).offstage, isTrue);
      expect(find.byKey(_kKeys[1]), findsOneWidget);
    });

    testWidgets('a retarget mid-slide restarts from the new pair', (
      tester,
    ) async {
      await _pump(tester, index: 0);
      await _pump(tester, index: 1);
      await tester.pump(_kDuration ~/ 2);

      await _pump(tester, index: 2);

      expect(_entryOffset(tester, 2), const Offset(1, 0));
      expect(_transitionOf(1), findsOneWidget);
      expect(_offstageOf(tester, 0).offstage, isTrue);

      await tester.pumpAndSettle();
      expect(_allTransitions(), findsNothing);
    });

    testWidgets('a rebuild with the same index starts no slide', (
      tester,
    ) async {
      await _pump(tester, index: 0);
      await _pump(
        tester,
        index: 0,
        duration: const Duration(milliseconds: 400),
      );

      expect(_allTransitions(), findsNothing);
    });
  });
}
