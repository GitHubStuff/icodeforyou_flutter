// packages/spinners/test/src/spin_widget/spin_widget_test.dart

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spinners/spinners.dart' show SpinController, SpinWidget;

/// Exposes [notifyListeners] so a test can fire a notification that does not
/// change the epoch.
class _PingController extends SpinController {
  _PingController({super.rpm});

  void ping() => notifyListeners();
}

Widget _harness(Widget child) => Center(child: child);

/// Asserts that the single [Transform] in the tree rotates by [degrees].
void _expectRotation(WidgetTester tester, double degrees) {
  final transform = tester.widget<Transform>(find.byType(Transform));
  final expected = Matrix4.rotationZ(degrees * math.pi / 180);
  for (var i = 0; i < 16; i++) {
    expect(
      transform.transform.storage[i],
      moreOrLessEquals(expected.storage[i]),
      reason: 'matrix entry $i for $degrees°',
    );
  }
}

Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

/// Runs [body] with [debugPrint] redirected into the returned list.
///
/// The original callback is restored before this returns, because the test
/// binding verifies that foundation debug variables are untouched at the end
/// of the test body — before any [addTearDown] callback runs.
Future<List<String?>> _capturingDebugPrint(
  Future<void> Function() body,
) async {
  final messages = <String?>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    messages.add(message);
  };
  try {
    await body();
  } finally {
    debugPrint = original;
  }
  return messages;
}

void main() {
  group('SpinWidget', () {
    group('constructor', () {
      test('asserts on zero rpm', () {
        expect(
          () => SpinWidget(rpm: 0, child: SizedBox(key: UniqueKey())),
          throwsAssertionError,
        );
      });
    });

    group('owned controller', () {
      testWidgets('stays still when autoStart is false', (tester) async {
        await tester.pumpWidget(
          _harness(const SpinWidget(rpm: 60, child: SizedBox.square())),
        );
        _expectRotation(tester, 0);

        await tester.pump(const Duration(milliseconds: 500));
        _expectRotation(tester, 0);

        await _unmount(tester);
      });

      testWidgets('spins from first build when autoStart is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          _harness(
            const SpinWidget(
              rpm: 60,
              autoStart: true,
              child: SizedBox.square(),
            ),
          ),
        );
        await tester.pump();
        _expectRotation(tester, 0);

        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 90);

        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 180);

        // Disposing while spinning must not throw.
        await _unmount(tester);
      });

      testWidgets('spins counter-clockwise for a negative rpm', (tester) async {
        await tester.pumpWidget(
          _harness(
            const SpinWidget(
              rpm: -60,
              autoStart: true,
              child: SizedBox.square(),
            ),
          ),
        );
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 270);

        await _unmount(tester);
      });
    });

    group('external controller', () {
      testWidgets('follows start, stop, resume and reset', (tester) async {
        final controller = SpinController(rpm: 60);
        addTearDown(controller.dispose);
        controller.start(angle: 90);

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: controller, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        _expectRotation(tester, 90);

        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 180);

        expect(controller.stop(), moreOrLessEquals(180));
        await tester.pump();
        _expectRotation(tester, 180);

        await tester.pump(const Duration(milliseconds: 500));
        _expectRotation(tester, 180);

        controller.resume();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 270);

        controller.reset(angle: 45);
        await tester.pump();
        _expectRotation(tester, 45);

        await tester.pump(const Duration(milliseconds: 500));
        _expectRotation(tester, 45);

        controller.reset();
        await tester.pump();
        _expectRotation(tester, 90);

        await _unmount(tester);
        // The widget detached on dispose, so the controller is attachable
        // again and was not disposed.
        expect(() => controller.attach(() => 0), returnsNormally);
      });

      testWidgets('changes speed without a visible jump', (tester) async {
        final controller = SpinController(rpm: 60);
        addTearDown(controller.dispose);
        controller.start();

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: controller, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 90);

        controller.rpm = 120;
        await tester.pump();
        _expectRotation(tester, 90);

        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 270);

        await _unmount(tester);
      });

      testWidgets('ignores a notification that does not change the epoch', (
        tester,
      ) async {
        final controller = _PingController(rpm: 60);
        addTearDown(controller.dispose);
        controller.start();

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: controller, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 90);

        controller.ping();
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 180);

        await _unmount(tester);
      });
    });

    group('didUpdateWidget', () {
      testWidgets('keeps the same controller attached', (tester) async {
        final controller = SpinController(rpm: 60);
        addTearDown(controller.dispose);
        controller.start();

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: controller, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: controller, child: const SizedBox.square()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 90);

        await _unmount(tester);
      });

      testWidgets('swaps one external controller for another', (tester) async {
        final first = SpinController(rpm: 60);
        final second = SpinController(rpm: 60);
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        first.start(angle: 90);
        second.reset(angle: 45);

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: first, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        _expectRotation(tester, 90);

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: second, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        _expectRotation(tester, 45);
        expect(() => first.attach(() => 0), returnsNormally);

        await tester.pump(const Duration(milliseconds: 500));
        _expectRotation(tester, 45);

        await _unmount(tester);
        expect(() => second.attach(() => 0), returnsNormally);
      });

      testWidgets('replaces an owned controller with an external one', (
        tester,
      ) async {
        final external = SpinController(rpm: 60);
        addTearDown(external.dispose);
        external.reset(angle: 45);

        await tester.pumpWidget(
          _harness(
            const SpinWidget(
              rpm: 60,
              autoStart: true,
              child: SizedBox.square(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        _expectRotation(tester, 90);

        await tester.pumpWidget(
          _harness(
            SpinWidget(controller: external, child: const SizedBox.square()),
          ),
        );
        await tester.pump();
        _expectRotation(tester, 45);

        await _unmount(tester);
      });
    });

    group('build', () {
      testWidgets('forwards alignment and filterQuality', (tester) async {
        await tester.pumpWidget(
          _harness(
            const SpinWidget(
              alignment: Alignment.topLeft,
              filterQuality: FilterQuality.high,
              child: SizedBox.square(),
            ),
          ),
        );

        final transform = tester.widget<Transform>(find.byType(Transform));
        expect(transform.alignment, Alignment.topLeft);
        expect(transform.filterQuality, FilterQuality.high);
        expect(find.byType(RepaintBoundary), findsOneWidget);

        await _unmount(tester);
      });
    });

    group('refresh-rate check', () {
      testWidgets('is silent at a smooth speed', (tester) async {
        tester.view.display.refreshRate = 60;
        addTearDown(tester.view.display.resetRefreshRate);

        final messages = await _capturingDebugPrint(() async {
          await tester.pumpWidget(
            _harness(
              const SpinWidget(
                rpm: 60,
                autoStart: true,
                child: SizedBox.square(),
              ),
            ),
          );
        });

        expect(messages, isEmpty);
        await _unmount(tester);
      });

      testWidgets('warns about strobing above 15° per frame', (tester) async {
        tester.view.display.refreshRate = 60;
        addTearDown(tester.view.display.resetRefreshRate);

        // 600 rpm at 60 Hz advances 60° per frame.
        final messages = await _capturingDebugPrint(() async {
          await tester.pumpWidget(
            _harness(
              const SpinWidget(
                rpm: 600,
                autoStart: true,
                child: SizedBox.square(),
              ),
            ),
          );
        });

        expect(messages, hasLength(1));
        expect(messages.single, contains('strobe'));
        expect(messages.single, contains('60.0° per frame'));
        expect(messages.single, contains('Keep |rpm| <= 150'));
        await _unmount(tester);
      });

      testWidgets('asserts above the 180° per frame aliasing limit', (
        tester,
      ) async {
        tester.view.display.refreshRate = 60;
        addTearDown(tester.view.display.resetRefreshRate);

        // 3600 rpm at 60 Hz advances 360° per frame, which also trips the
        // strobe warning; swallow it so it does not reach the console.
        await _capturingDebugPrint(() async {
          await tester.pumpWidget(
            _harness(
              const SpinWidget(
                rpm: 3600,
                autoStart: true,
                child: SizedBox.square(),
              ),
            ),
          );
        });

        final error = tester.takeException();
        expect(error, isAssertionError);
        expect(
          (error as AssertionError).message,
          contains('aliasing limit of 1800 rpm'),
        );
      });
    });
  });
}
