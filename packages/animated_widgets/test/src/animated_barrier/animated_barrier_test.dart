// packages/animated_widgets/test/src/animated_barrier/animated_barrier_test.dart

import 'package:animated_widgets/animated_widgets.dart'
    show
        AnimatedBarrier,
        BarrierAnimation,
        FadeBarrier,
        PopoverHandle,
        PopoverPosition,
        SlideFromBottomBarrier,
        SlideFromTopBarrier;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// status_bar_chameleon's actual platform channel; verified from its source.
const MethodChannel _statusBarChannel = MethodChannel(
  'status_bar_chameleon/status_bar',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> statusBarCalls = [];

  setUp(() {
    statusBarCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_statusBarChannel, (call) async {
          statusBarCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_statusBarChannel, null);
  });

  group('PopoverHandle.dismiss', () {
    testWidgets('second dismiss invokes onComplete immediately', (
      tester,
    ) async {
      final handle = await _showCenter(tester);

      handle.dismiss();
      await tester.pumpAndSettle();

      var secondCompleted = false;
      handle.dismiss(onComplete: () => secondCompleted = true);
      expect(secondCompleted, isTrue);
    });

    testWidgets('second dismiss without onComplete is a no-op', (tester) async {
      final handle = await _showCenter(tester);

      handle.dismiss();
      await tester.pumpAndSettle();

      handle.dismiss();
    });
  });

  group('AnimatedBarrier.show', () {
    testWidgets('hides status bar when hideStatusBar is true', (tester) async {
      await _showCenter(tester, hideStatusBar: true);
      await tester.pumpAndSettle();
      expect(
        statusBarCalls.any(
          (c) =>
              c.method == 'setStatusBarHidden' &&
              (c.arguments as Map)['hidden'] == true,
        ),
        isTrue,
        reason: 'expected setStatusBarHidden(hidden: true) to be invoked',
      );
    });

    testWidgets('does not touch status bar when hideStatusBar is false', (
      tester,
    ) async {
      await _showCenter(tester, hideStatusBar: false);
      await tester.pumpAndSettle();
      expect(statusBarCalls, isEmpty);
    });

    testWidgets('onComplete fires when entrance animation finishes', (
      tester,
    ) async {
      var shown = false;
      await _showCenter(tester, onComplete: () => shown = true);

      expect(shown, isFalse, reason: 'should not fire before settle');
      await tester.pumpAndSettle();
      expect(shown, isTrue);
    });
  });

  group('AnimatedBarrier.dismiss', () {
    testWidgets('onComplete fires after exit animation', (tester) async {
      final handle = await _showCenter(tester);
      await tester.pumpAndSettle();

      var dismissed = false;
      handle.dismiss(onComplete: () => dismissed = true);

      expect(dismissed, isFalse, reason: 'fires only after reverse completes');
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('restores status bar when hideStatusBar was true', (
      tester,
    ) async {
      final handle = await _showCenter(tester, hideStatusBar: true);
      await tester.pumpAndSettle();
      statusBarCalls.clear();

      handle.dismiss();
      await tester.pumpAndSettle();

      expect(
        statusBarCalls.any(
          (c) =>
              c.method == 'setStatusBarHidden' &&
              (c.arguments as Map)['hidden'] == false,
        ),
        isTrue,
        reason: 'expected setStatusBarHidden(hidden: false) on dismiss',
      );
    });

    testWidgets('does not restore status bar when hideStatusBar was false', (
      tester,
    ) async {
      final handle = await _showCenter(tester, hideStatusBar: false);
      await tester.pumpAndSettle();
      statusBarCalls.clear();

      handle.dismiss();
      await tester.pumpAndSettle();

      expect(statusBarCalls, isEmpty);
    });

    testWidgets('reverse from mid-forward still settles', (tester) async {
      final handle = await _showCenter(tester);
      await tester.pump(const Duration(milliseconds: 100));

      var dismissed = false;
      handle.dismiss(onComplete: () => dismissed = true);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('barrier tap', () {
    testWidgets('dismisses when barrierDismissible is true', (tester) async {
      final handle = await _showCenter(tester, barrierDismissible: true);
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsNothing);
      var second = false;
      handle.dismiss(onComplete: () => second = true);
      expect(second, isTrue);
    });

    testWidgets('does not dismiss when barrierDismissible is false', (
      tester,
    ) async {
      await _showCenter(tester, barrierDismissible: false);
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
    });
  });

  group('barrier animation variants', () {
    testWidgets('FadeBarrier renders and dismisses', (tester) async {
      final handle = await _showCenter(
        tester,
        animation: const FadeBarrier(),
      );
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('SlideFromTopBarrier renders and dismisses', (tester) async {
      final handle = await _showCenter(
        tester,
        animation: const SlideFromTopBarrier(),
      );
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('SlideFromBottomBarrier renders and dismisses', (tester) async {
      final handle = await _showCenter(
        tester,
        animation: const SlideFromBottomBarrier(),
      );
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('anchored positions', () {
    testWidgets('PopoverPosition.below with a visible anchor lays out', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await _pumpHostWithAnchor(tester, anchorKey);

      final handle = AnimatedBarrier(
        position: PopoverPosition.below(anchorKey),
        child: const SizedBox(width: 100, height: 50, child: Text('content')),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('PopoverPosition.above with a visible anchor lays out', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await _pumpHostWithAnchor(tester, anchorKey);

      final handle = AnimatedBarrier(
        position: PopoverPosition.above(anchorKey),
        child: const SizedBox(width: 100, height: 50, child: Text('content')),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('PopoverPosition.left with a visible anchor lays out', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await _pumpHostWithAnchor(tester, anchorKey);

      final handle = AnimatedBarrier(
        position: PopoverPosition.left(anchorKey),
        child: const SizedBox(width: 100, height: 50, child: Text('content')),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('PopoverPosition.right with a visible anchor lays out', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await _pumpHostWithAnchor(tester, anchorKey);

      final handle = AnimatedBarrier(
        position: PopoverPosition.right(anchorKey),
        child: const SizedBox(width: 100, height: 50, child: Text('content')),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'missing anchor dismisses post-frame (covers anchorVisible == false)',
      (tester) async {
        final unmountedKey = GlobalKey();
        await _pumpHost(tester);

        AnimatedBarrier(
          position: PopoverPosition.below(unmountedKey),
          child: const Text('content'),
        ).show(_overlayContext(tester));
        await tester.pumpAndSettle();

        expect(find.text('content'), findsNothing);
      },
    );

    testWidgets('preferred side that does not fit falls back through chain', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                key: anchorKey,
                width: 20,
                height: 20,
                color: const Color(0xFFFF0000),
              ),
            ),
          ),
        ),
      );

      final handle = AnimatedBarrier(
        position: PopoverPosition.right(anchorKey),
        childSize: const Size(400, 100),
        child: const Text('content'),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('child larger than bounds triggers inverted-range clamp', (
      tester,
    ) async {
      final anchorKey = GlobalKey();
      await _pumpHostWithAnchor(tester, anchorKey);

      final handle = AnimatedBarrier(
        position: PopoverPosition.below(anchorKey),
        childSize: const Size(10000, 10000),
        child: const Text('content'),
      ).show(_overlayContext(tester));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsOneWidget);
      handle.dismiss();
      await tester.pumpAndSettle();
    });
  });
}

Future<void> _pumpHost(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: SizedBox.expand()),
    ),
  );
}

Future<void> _pumpHostWithAnchor(
  WidgetTester tester,
  GlobalKey anchorKey,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            key: anchorKey,
            width: 50,
            height: 50,
            color: const Color(0xFF00FF00),
          ),
        ),
      ),
    ),
  );
}

BuildContext _overlayContext(WidgetTester tester) =>
    tester.element(find.byType(Scaffold));

Future<PopoverHandle> _showCenter(
  WidgetTester tester, {
  bool hideStatusBar = true,
  bool barrierDismissible = true,
  BarrierAnimation animation = const FadeBarrier(),
  VoidCallback? onComplete,
}) async {
  await _pumpHost(tester);
  final handle = AnimatedBarrier(
    barrierDismissible: barrierDismissible,
    barrierAnimation: animation,
    child: const Text('content'),
  ).show(_overlayContext(tester), onComplete: onComplete);
  await tester.pump();
  return handle;
}
