// test/haptics/haptic_intensity_wrap_test.dart
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <String>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('HapticIntensity.wrap', () {
    test('returns null when the callback is null', () {
      expect(HapticIntensity.light.wrap(null), isNull);
    });

    test('returns a wrapper that triggers then runs the callback', () async {
      var ran = false;
      final wrapped = HapticIntensity.light.wrap(() => ran = true);
      expect(wrapped, isNotNull);

      wrapped!();
      await Future<void>.delayed(Duration.zero);

      expect(ran, isTrue);
      expect(calls, contains('HapticFeedback.vibrate'));
    });

    test('none-intensity wrapper runs the callback without a platform call',
        () async {
      var ran = false;
      HapticIntensity.none.wrap(() => ran = true)!();
      await Future<void>.delayed(Duration.zero);

      expect(ran, isTrue);
      expect(calls, isEmpty);
    });
  });

  group('HapticIntensity.wrapValue', () {
    test('returns null when the callback is null', () {
      expect(HapticIntensity.light.wrapValue<int>(null), isNull);
    });

    test('returns a wrapper that triggers then forwards the value', () async {
      int? received;
      final wrapped =
          HapticIntensity.medium.wrapValue<int>((v) => received = v);
      expect(wrapped, isNotNull);

      wrapped!(42);
      await Future<void>.delayed(Duration.zero);

      expect(received, 42);
      expect(calls, contains('HapticFeedback.vibrate'));
    });

    test('none-intensity wrapper forwards the value without a platform call',
        () async {
      int? received;
      HapticIntensity.none.wrapValue<int>((v) => received = v)!(7);
      await Future<void>.delayed(Duration.zero);

      expect(received, 7);
      expect(calls, isEmpty);
    });
  });
}
