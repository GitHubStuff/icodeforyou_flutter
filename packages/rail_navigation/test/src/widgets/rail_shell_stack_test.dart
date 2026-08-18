// packages/rail_navigation/test/src/widgets/rail_shell_stack_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_shell.dart';

const Duration _kDuration = Duration(milliseconds: 400);

/// A screen whose count survives only if the stack keeps it alive.
class _Counter extends StatefulWidget {
  const _Counter({required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => _count++),
        child: Text('${widget.label}:$_count'),
      ),
    );
  }
}

Widget _shell({
  int currentIndex = 0,
  RailTransition transition = RailTransition.fadeThrough,
  Duration transitionDuration = _kDuration,
}) {
  return MaterialApp(
    home: RailShell(
      currentIndex: currentIndex,
      transition: transition,
      transitionDuration: transitionDuration,
      railChildren: const [SizedBox(width: 48, height: 48)],
      screens: const [
        _Counter(label: 'A'),
        _Counter(label: 'B'),
        _Counter(label: 'C'),
      ],
    ),
  );
}

void main() {
  group('transitioning stack', () {
    testWidgets('mounts every screen but stages only the current one', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());

      expect(find.text('A:0'), findsOneWidget);
      expect(find.text('B:0'), findsNothing);
      expect(find.text('B:0', skipOffstage: false), findsOneWidget);
      expect(find.text('C:0', skipOffstage: false), findsOneWidget);
    });

    testWidgets('preserves screen state across switches', (tester) async {
      await tester.pumpWidget(_shell());

      await tester.tap(find.text('A:0'));
      await tester.pump();
      expect(find.text('A:1'), findsOneWidget);

      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pumpAndSettle();
      expect(find.text('B:0'), findsOneWidget);

      await tester.pumpWidget(_shell(currentIndex: 0));
      await tester.pumpAndSettle();
      expect(find.text('A:1'), findsOneWidget);
    });

    testWidgets('keeps the outgoing screen pointer-blocked mid-transition', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());
      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pump(_kDuration * 0.5);

      // Both layers are live; tapping the outgoing screen's button must
      // not reach it.
      await tester.tap(find.text('A:0'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('A:1', skipOffstage: false), findsNothing);
      expect(find.text('A:0', skipOffstage: false), findsOneWidget);
    });

    testWidgets('returns the outgoing layer to hidden on completion', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());
      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pump(_kDuration * 0.5);

      // Mid-transition both layers are staged.
      expect(find.text('A:0'), findsOneWidget);
      expect(find.text('B:0'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('B:0'), findsOneWidget);
      expect(find.text('A:0'), findsNothing);
      expect(find.text('A:0', skipOffstage: false), findsOneWidget);
    });

    testWidgets('ignores rebuilds that keep the same index', (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pumpWidget(
        _shell(transitionDuration: const Duration(milliseconds: 200)),
      );
      await tester.pump();

      expect(find.text('A:0'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('switches instantly when the transition is none', (
      tester,
    ) async {
      await tester.pumpWidget(_shell(transition: RailTransition.none));
      await tester.pumpWidget(
        _shell(currentIndex: 1, transition: RailTransition.none),
      );
      await tester.pump();

      expect(find.text('B:0'), findsOneWidget);
      expect(find.text('A:0'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('switches instantly when the duration is zero', (
      tester,
    ) async {
      await tester.pumpWidget(_shell(transitionDuration: Duration.zero));
      await tester.pumpWidget(
        _shell(currentIndex: 1, transitionDuration: Duration.zero),
      );
      await tester.pump();

      expect(find.text('B:0'), findsOneWidget);
      expect(find.text('A:0'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('switches instantly when the platform disables animations', (
      tester,
    ) async {
      Widget accessibleShell(int currentIndex) {
        return MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: RailShell(
            currentIndex: currentIndex,
            transitionDuration: _kDuration,
            railChildren: const [SizedBox(width: 48, height: 48)],
            screens: const [
              _Counter(label: 'A'),
              _Counter(label: 'B'),
            ],
          ),
        );
      }

      await tester.pumpWidget(accessibleShell(0));
      await tester.pumpWidget(accessibleShell(1));
      await tester.pump();

      expect(find.text('B:0'), findsOneWidget);
      expect(find.text('A:0'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('retargets cleanly when the index changes mid-transition', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());
      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pump(_kDuration * 0.5);

      await tester.pumpWidget(_shell(currentIndex: 2));
      await tester.pump(_kDuration * 0.5);

      // The interrupted screen is now the outgoing layer.
      expect(find.text('B:0'), findsOneWidget);
      expect(find.text('C:0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('C:0'), findsOneWidget);
      expect(find.text('B:0'), findsNothing);
    });

    testWidgets('disposes cleanly mid-transition', (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pump(_kDuration * 0.5);

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
