// test/src/haptic_feedback_type_test.dart

import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Captured (method, args) pairs from SystemChannels.platform during a
  /// single trigger() call.
  final List<({String method, Object? args})> calls = [];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add((method: call.method, args: call.arguments));
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Pumps microtasks so the `unawaited` futures from HapticFeedback.*
  /// have a chance to dispatch their MethodChannel calls before we assert.
  Future<void> drainMicrotasks() async {
    await Future<void>.delayed(Duration.zero);
  }

  group('HapticFeedbackType', () {
    test('declares all six values in expected order', () {
      expect(HapticIntensity.values, [
        HapticIntensity.light,
        HapticIntensity.medium,
        HapticIntensity.heavy,
        HapticIntensity.selection,
        HapticIntensity.vibrate,
        HapticIntensity.none,
      ]);
    });

    group('trigger()', () {
      test('light invokes HapticFeedback.lightImpact', () async {
        HapticIntensity.light.trigger();
        await drainMicrotasks();

        expect(calls, hasLength(1));
        expect(calls.single.method, 'HapticFeedback.vibrate');
        expect(calls.single.args, 'HapticFeedbackType.lightImpact');
      });

      test('medium invokes HapticFeedback.mediumImpact', () async {
        HapticIntensity.medium.trigger();
        await drainMicrotasks();

        expect(calls, hasLength(1));
        expect(calls.single.method, 'HapticFeedback.vibrate');
        expect(calls.single.args, 'HapticFeedbackType.mediumImpact');
      });

      test('heavy invokes HapticFeedback.heavyImpact', () async {
        HapticIntensity.heavy.trigger();
        await drainMicrotasks();

        expect(calls, hasLength(1));
        expect(calls.single.method, 'HapticFeedback.vibrate');
        expect(calls.single.args, 'HapticFeedbackType.heavyImpact');
      });

      test('selection invokes HapticFeedback.selectionClick', () async {
        HapticIntensity.selection.trigger();
        await drainMicrotasks();

        expect(calls, hasLength(1));
        expect(calls.single.method, 'HapticFeedback.vibrate');
        expect(calls.single.args, 'HapticFeedbackType.selectionClick');
      });

      test('vibrate invokes HapticFeedback.vibrate with null args', () async {
        HapticIntensity.vibrate.trigger();
        await drainMicrotasks();

        expect(calls, hasLength(1));
        expect(calls.single.method, 'HapticFeedback.vibrate');
        expect(calls.single.args, isNull);
      });

      test('none invokes nothing', () async {
        HapticIntensity.none.trigger();
        await drainMicrotasks();

        expect(calls, isEmpty);
      });
    });
  });
}
