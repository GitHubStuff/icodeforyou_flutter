// test/enum/src/haptic_intensity_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart'
    show HapticIntensity;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          log.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Flushes the microtask queue so fire-and-forget platform messages land.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('HapticIntensity.trigger', () {
    test('light sends a lightImpact haptic', () async {
      HapticIntensity.light.trigger();
      await flush();
      expect(log.single.method, 'HapticFeedback.vibrate');
      expect(log.single.arguments, 'HapticFeedbackType.lightImpact');
    });

    test('medium sends a mediumImpact haptic', () async {
      HapticIntensity.medium.trigger();
      await flush();
      expect(log.single.arguments, 'HapticFeedbackType.mediumImpact');
    });

    test('heavy sends a heavyImpact haptic', () async {
      HapticIntensity.heavy.trigger();
      await flush();
      expect(log.single.arguments, 'HapticFeedbackType.heavyImpact');
    });

    test('selection sends a selectionClick haptic', () async {
      HapticIntensity.selection.trigger();
      await flush();
      expect(log.single.arguments, 'HapticFeedbackType.selectionClick');
    });

    test('vibrate sends a plain vibrate haptic', () async {
      HapticIntensity.vibrate.trigger();
      await flush();
      expect(log.single.method, 'HapticFeedback.vibrate');
    });

    test('none sends nothing', () async {
      HapticIntensity.none.trigger();
      await flush();
      expect(log, isEmpty);
    });
  });

  group('HapticIntensity.wrap', () {
    test('returns null for a null callback', () {
      expect(HapticIntensity.light.wrap(null), isNull);
    });

    test('fires the haptic then the callback', () async {
      var called = false;
      final wrapped = HapticIntensity.medium.wrap(() => called = true);
      wrapped!();
      await flush();
      expect(called, isTrue);
      expect(log.single.arguments, 'HapticFeedbackType.mediumImpact');
    });
  });

  group('HapticIntensity.wrapValue', () {
    test('returns null for a null callback', () {
      expect(HapticIntensity.selection.wrapValue<int>(null), isNull);
    });

    test('fires the haptic then forwards the value', () async {
      int? received;
      final wrapped = HapticIntensity.selection.wrapValue<int>(
        (value) => received = value,
      );
      wrapped!(42);
      await flush();
      expect(received, 42);
      expect(log.single.arguments, 'HapticFeedbackType.selectionClick');
    });
  });
}
