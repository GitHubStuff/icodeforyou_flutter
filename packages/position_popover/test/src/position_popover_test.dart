// packages/position_popover/test/src/position_popover_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:position_popover/position_popover.dart' show PositionPopover;
import 'package:position_popover/src/popover_layout_delegate.dart'
    show PopoverLayoutDelegate;
import 'package:position_popover/src/position_popover_route.dart'
    show PositionPopoverRoute;

const Size _area = Size(400, 800);
const Key _parentKey = Key('parent');
const Key _popoverKey = Key('popover');
const Key _leadingKey = Key('leading');
const Key _trailingKey = Key('trailing');

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(_area);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  Future<void> tapParent(WidgetTester tester) async {
    await tester.tap(find.byKey(_parentKey));
    await tester.pumpAndSettle();
  }

  PositionPopoverRoute<String> currentRoute(WidgetTester tester) {
    final context = tester.element(find.byKey(_popoverKey));
    return ModalRoute.of(context)! as PositionPopoverRoute<String>;
  }

  group('PositionPopover', () {
    test('standard is the documented alignment', () {
      expect(PositionPopover.standard, const Alignment(0.6, 0.8));
    });

    group('rendering', () {
      testWidgets('renders only the parent when icons are null', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        expect(find.byKey(_parentKey), findsOneWidget);
        expect(find.byKey(_leadingKey), findsNothing);
        expect(find.byKey(_trailingKey), findsNothing);
      });

      testWidgets('renders leading and trailing icons around the parent', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            leadingIcon: _Icon(key: _leadingKey),
            trailingIcon: _Icon(key: _trailingKey),
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        final leading = tester.getRect(find.byKey(_leadingKey));
        final parent = tester.getRect(find.byKey(_parentKey));
        final trailing = tester.getRect(find.byKey(_trailingKey));
        expect(leading.right, lessThanOrEqualTo(parent.left));
        expect(parent.right, lessThanOrEqualTo(trailing.left));
      });

      testWidgets('applies decoration and padding to the whole row', (
        tester,
      ) async {
        const decoration = BoxDecoration(color: Colors.red);
        const padding = EdgeInsets.all(12);
        await pump(
          tester,
          const PositionPopover<String>(
            decoration: decoration,
            padding: padding,
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.byType(Row),
            matching: find.byType(Container),
          ),
        );
        expect(container.decoration, decoration);
        expect(container.padding, padding);
      });
    });

    group('opening', () {
      testWidgets('tapping the parent shows the popover', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        await tapParent(tester);

        expect(find.byKey(_popoverKey), findsOneWidget);
      });

      testWidgets('tapping an icon does not open the popover', (
        tester,
      ) async {
        await pump(
          tester,
          PositionPopover<String>(
            leadingIcon: GestureDetector(
              key: _leadingKey,
              onTap: () {},
              child: const _Icon(),
            ),
            trailingIcon: GestureDetector(
              key: _trailingKey,
              onTap: () {},
              child: const _Icon(),
            ),
            parent: const _Parent(),
            popover: const _Popover(),
          ),
        );

        await tester.tap(find.byKey(_leadingKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(_trailingKey));
        await tester.pumpAndSettle();

        expect(find.byKey(_popoverKey), findsNothing);
      });

      testWidgets('fires the haptic on open', (tester) async {
        final calls = <MethodCall>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            calls.add(call);
            return null;
          },
        );
        addTearDown(() {
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          );
        });
        await pump(
          tester,
          const PositionPopover<String>(
            hapticIntensity: HapticIntensity.light,
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        await tapParent(tester);

        expect(
          calls.map((c) => c.method),
          contains('HapticFeedback.vibrate'),
        );
      });
    });

    group('anchor', () {
      testWidgets('is the parent rectangle, excluding icons and padding', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red),
            leadingIcon: _Icon(key: _leadingKey),
            trailingIcon: _Icon(key: _trailingKey),
            parent: _Parent(),
            popover: _Popover(),
          ),
        );
        final parentRect = tester.getRect(find.byKey(_parentKey));

        await tapParent(tester);

        expect(currentRoute(tester).anchor, parentRect);
      });
    });

    group('route configuration', () {
      testWidgets('forwards every popover argument to the route', (
        tester,
      ) async {
        const timeout = Duration(seconds: 5);
        await pump(
          tester,
          const PositionPopover<String>(
            alignment: Alignment.topLeft,
            barrierDismissible: false,
            barrierColor: Colors.red,
            timeout: timeout,
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        await tapParent(tester);

        final route = currentRoute(tester);
        expect(route.alignment, Alignment.topLeft);
        expect(route.barrierDismissible, isFalse);
        expect(route.barrierColor, Colors.red);
        expect(route.timeout, timeout);
        expect(route.popover, isA<_Popover>());
      });

      testWidgets('uses the documented defaults', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        await tapParent(tester);

        final route = currentRoute(tester);
        expect(route.alignment, PositionPopover.standard);
        expect(route.barrierDismissible, isTrue);
        expect(route.barrierColor, Colors.black54);
        expect(route.timeout, isNull);
      });

      testWidgets('positions the popover with the forwarded alignment', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            alignment: Alignment.topCenter,
            parent: _Parent(),
            popover: _Popover(),
          ),
        );

        await tapParent(tester);

        final route = currentRoute(tester);
        final delegate = PopoverLayoutDelegate(
          anchor: route.anchor,
          alignment: route.alignment,
        );
        final expected = delegate.getPositionForChild(
          _area,
          tester.getSize(find.byKey(_popoverKey)),
        );
        expect(tester.getTopLeft(find.byKey(_popoverKey)), expected);
      });
    });

    group('results', () {
      testWidgets('delivers the popped value to onResult', (
        tester,
      ) async {
        final results = <String?>[];
        await pump(
          tester,
          PositionPopover<String>(
            onResult: results.add,
            parent: const _Parent(),
            popover: const _Popover(),
          ),
        );
        await tapParent(tester);

        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();

        expect(results, <String?>['picked']);
      });

      testWidgets('delivers null on barrier dismissal', (
        tester,
      ) async {
        final results = <String?>[];
        await pump(
          tester,
          PositionPopover<String>(
            onResult: results.add,
            parent: const _Parent(),
            popover: const _Popover(),
          ),
        );
        await tapParent(tester);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(results, <String?>[null]);
      });

      testWidgets('discards the result when onResult is null', (
        tester,
      ) async {
        await pump(
          tester,
          const PositionPopover<String>(
            parent: _Parent(),
            popover: _Popover(),
          ),
        );
        await tapParent(tester);

        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();

        expect(find.byKey(_popoverKey), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });
}

/// A fixed-size, hit-testable tappable parent.
///
/// [ColoredBox] is used rather than a bare [SizedBox] because an empty
/// [SizedBox] does not hit-test itself, which makes [WidgetTester.tap]
/// warn even though the surrounding gesture detector receives the tap.
class _Parent extends StatelessWidget {
  const _Parent();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      key: _parentKey,
      color: Colors.transparent,
      child: SizedBox(width: 120, height: 40),
    );
  }
}

/// A fixed-size, hit-testable stand-in for a leading or trailing icon.
class _Icon extends StatelessWidget {
  const _Icon({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.transparent,
      child: SizedBox(width: 24, height: 24),
    );
  }
}

/// A popover with one button that pops with `'picked'`.
class _Popover extends StatelessWidget {
  const _Popover();

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _popoverKey,
      child: SizedBox(
        width: 200,
        height: 100,
        child: TextButton(
          onPressed: () => Navigator.pop<String>(context, 'picked'),
          child: const Text('pick'),
        ),
      ),
    );
  }
}
