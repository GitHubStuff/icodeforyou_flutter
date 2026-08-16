// packages/custom_widgets/test/src/slide_index_stack/slide_index_stack_test.dart

import 'package:custom_widgets/src/slide_index_stack/slide_index_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _keyA = ValueKey<String>('a');
const Key _keyB = ValueKey<String>('b');
const Key _keyC = ValueKey<String>('c');

const Duration _testDuration = Duration(milliseconds: 300);

/// Wraps a [SlideIndexedStack] in a minimal app shell.
Widget _harness({
  required int index,
  Duration duration = _testDuration,
  Curve curve = Curves.easeInOutCubic,
  List<Widget> children = const <Widget>[
    SizedBox(key: _keyA),
    SizedBox(key: _keyB),
    SizedBox(key: _keyC),
  ],
}) {
  return MaterialApp(
    home: Scaffold(
      body: SlideIndexedStack(
        index: index,
        duration: duration,
        curve: curve,
        children: children,
      ),
    ),
  );
}

/// Every [SlideTransition] the stack owns, on stage or off.
///
/// `skipOffstage: false` must be set on the descendant finder itself,
/// not only the matcher: it governs the tree traversal, and hidden
/// children live inside [Offstage] subtrees.
Finder _slides() => find.descendant(
  of: find.byType(SlideIndexedStack),
  matching: find.byType(SlideTransition, skipOffstage: false),
  skipOffstage: false,
);

/// The [SlideTransition] wrapping the child at [key].
SlideTransition _slideOf(WidgetTester tester, Key key) {
  return tester.widget<SlideTransition>(
    find
        .ancestor(
          of: find.byKey(key, skipOffstage: false),
          matching: find.byType(SlideTransition, skipOffstage: false),
        )
        .first,
  );
}

/// The [Offstage] wrapping the child at [key].
Offstage _offstageOf(WidgetTester tester, Key key) {
  return tester.widget<Offstage>(
    find
        .ancestor(
          of: find.byKey(key, skipOffstage: false),
          matching: find.byType(Offstage, skipOffstage: false),
        )
        .first,
  );
}

/// Whether tickers are enabled at the child at [key].
bool _tickersEnabledAt(WidgetTester tester, Key key) {
  return TickerMode.of(tester.element(find.byKey(key, skipOffstage: false)));
}

void main() {
  group(SlideIndexedStack, () {
    test('exposes the documented defaults', () {
      const stack = SlideIndexedStack(index: 0, children: <Widget>[]);
      expect(stack.duration, const Duration(milliseconds: 750));
      expect(stack.curve, Curves.easeInOutCubic);
    });

    testWidgets(
      'at rest, keeps the identical wrapper chain for every child: '
      'the selected child on stage at center, the rest offstage with '
      'tickers disabled',
      (tester) async {
        await tester.pumpWidget(_harness(index: 0));

        // One permanent SlideTransition per child — the constant
        // wrapper chain that makes state survive.
        expect(_slides(), findsNWidgets(3));

        // The selected child: on stage, tickers live, held at center.
        expect(_offstageOf(tester, _keyA).offstage, isFalse);
        expect(_tickersEnabledAt(tester, _keyA), isTrue);
        expect(_slideOf(tester, _keyA).position.value, Offset.zero);

        // The rest: mounted, hidden, ticker-frozen, held at center.
        for (final key in <Key>[_keyB, _keyC]) {
          expect(find.byKey(key, skipOffstage: false), findsOneWidget);
          expect(_offstageOf(tester, key).offstage, isTrue);
          expect(_tickersEnabledAt(tester, key), isFalse);
          expect(_slideOf(tester, key).position.value, Offset.zero);
        }
      },
    );

    testWidgets(
      'ignores an update that keeps the same index',
      (tester) async {
        await tester.pumpWidget(_harness(index: 1));
        await tester.pumpWidget(
          _harness(index: 1, duration: const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // No slide started: nothing moved, nothing came on stage.
        expect(_offstageOf(tester, _keyB).offstage, isFalse);
        expect(_slideOf(tester, _keyB).position.value, Offset.zero);
        expect(_offstageOf(tester, _keyA).offstage, isTrue);
        expect(_offstageOf(tester, _keyC).offstage, isTrue);
      },
    );

    testWidgets(
      'slides forward when the index increases: the incoming child '
      'enters from the end',
      (tester) async {
        await tester.pumpWidget(_harness(index: 0));
        await tester.pumpWidget(_harness(index: 2));

        // The sliding pair comes on stage; the bystander stays off.
        expect(_offstageOf(tester, _keyA).offstage, isFalse);
        expect(_offstageOf(tester, _keyC).offstage, isFalse);
        expect(_offstageOf(tester, _keyB).offstage, isTrue);
        expect(_tickersEnabledAt(tester, _keyB), isFalse);
        expect(_slideOf(tester, _keyB).position.value, Offset.zero);

        // At t=0 the incoming child sits fully off the end; the
        // outgoing child sits at center.
        expect(_slideOf(tester, _keyC).position.value, const Offset(1, 0));
        expect(_slideOf(tester, _keyA).position.value, Offset.zero);

        // Mid-slide, both remain on stage.
        await tester.pump(const Duration(milliseconds: 150));
        expect(_offstageOf(tester, _keyA).offstage, isFalse);
        expect(_offstageOf(tester, _keyC).offstage, isFalse);

        // At rest again: the previous child is dropped back offstage
        // and the new selection holds center.
        await tester.pumpAndSettle();
        expect(_offstageOf(tester, _keyC).offstage, isFalse);
        expect(_slideOf(tester, _keyC).position.value, Offset.zero);
        expect(_offstageOf(tester, _keyA).offstage, isTrue);
        expect(_tickersEnabledAt(tester, _keyA), isFalse);
      },
    );

    testWidgets(
      'slides backward when the index decreases: the incoming child '
      'enters from the start',
      (tester) async {
        await tester.pumpWidget(_harness(index: 2));
        await tester.pumpWidget(_harness(index: 0));

        expect(_slideOf(tester, _keyA).position.value, const Offset(-1, 0));
        expect(_slideOf(tester, _keyC).position.value, Offset.zero);

        await tester.pumpAndSettle();
        expect(_offstageOf(tester, _keyA).offstage, isFalse);
        expect(_offstageOf(tester, _keyC).offstage, isTrue);
      },
    );

    testWidgets(
      'shapes both the incoming and outgoing slides with the '
      'provided curve',
      (tester) async {
        await tester.pumpWidget(_harness(index: 0, curve: Curves.linear));
        await tester.pumpWidget(_harness(index: 1, curve: Curves.linear));

        // Halfway through a linear slide, both children sit halfway.
        await tester.pump(const Duration(milliseconds: 150));
        expect(_slideOf(tester, _keyB).position.value, const Offset(0.5, 0));
        expect(_slideOf(tester, _keyA).position.value, const Offset(-0.5, 0));

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'restarts a mid-slide change from the new previous/current pair',
      (tester) async {
        await tester.pumpWidget(_harness(index: 0));
        await tester.pumpWidget(_harness(index: 1));
        await tester.pump(const Duration(milliseconds: 100));

        // A tap mid-slide: the pair becomes (previous: b, current: c)
        // and the controller restarts from zero.
        await tester.pumpWidget(_harness(index: 2));
        expect(_slideOf(tester, _keyC).position.value, const Offset(1, 0));
        expect(_slideOf(tester, _keyB).position.value, Offset.zero);
        expect(_offstageOf(tester, _keyB).offstage, isFalse);
        expect(_offstageOf(tester, _keyA).offstage, isTrue);

        await tester.pumpAndSettle();
        expect(_offstageOf(tester, _keyC).offstage, isFalse);
        expect(_offstageOf(tester, _keyB).offstage, isTrue);
      },
    );

    testWidgets(
      'applies an updated duration to the next slide',
      (tester) async {
        await tester.pumpWidget(_harness(index: 0));
        await tester.pumpWidget(
          _harness(index: 1, duration: const Duration(milliseconds: 100)),
        );

        // At exactly the new duration the slide has visually landed:
        // completion has not yet dispatched (that takes one more
        // tick past the end), so both children are still on stage
        // with the tweens at their end values.
        await tester.pump(const Duration(milliseconds: 100));
        expect(_slideOf(tester, _keyB).position.value, Offset.zero);
        expect(_slideOf(tester, _keyA).position.value, const Offset(-1, 0));
        expect(_offstageOf(tester, _keyA).offstage, isFalse);

        // One tick past the end dispatches completed and drops the
        // previous child back offstage.
        await tester.pump(const Duration(milliseconds: 1));
        expect(_offstageOf(tester, _keyA).offstage, isTrue);
        expect(_offstageOf(tester, _keyB).offstage, isFalse);
        expect(_slideOf(tester, _keyB).position.value, Offset.zero);
      },
    );

    testWidgets(
      'preserves child state across index changes',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            index: 0,
            children: const <Widget>[
              _Counter(key: _keyA),
              SizedBox(key: _keyB),
            ],
          ),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pump();
        expect(find.text('count: 1'), findsOneWidget);

        // Switch away and back; the counter's state must survive.
        await tester.pumpWidget(
          _harness(
            index: 1,
            children: const <Widget>[
              _Counter(key: _keyA),
              SizedBox(key: _keyB),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          _harness(
            index: 0,
            children: const <Widget>[
              _Counter(key: _keyA),
              SizedBox(key: _keyB),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('count: 1'), findsOneWidget);
      },
    );

    testWidgets('disposes its controller cleanly', (tester) async {
      await tester.pumpWidget(_harness(index: 0));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}

/// A stateful child used to prove the [IndexedStack] state-keeping
/// contract survives slides.
class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

/// State for [_Counter]: a tap count that must survive switches.
class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => _count++),
      child: Text('count: $_count'),
    );
  }
}
