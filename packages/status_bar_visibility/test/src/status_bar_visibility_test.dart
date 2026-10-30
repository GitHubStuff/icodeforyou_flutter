// test/src/status_bar_visibility_test.dart

import 'package:custom_errors/custom_errors.dart' show NotInitializedError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_visibility/status_bar_visibility.dart'
    show StatusBarVisibility;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const androidChannel = MethodChannel('status_bar_android');
  const iosChannel = MethodChannel('status_bar_ios');

  setUp(() {
    StatusBarVisibility.reset();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidChannel, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iosChannel, (call) async => null);
  });

  tearDown(() {
    StatusBarVisibility.reset();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(androidChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iosChannel, null);
  });

  group('StatusBarVisibility', () {
    test('initial state: isHidden is null before initialization', () {
      expect(StatusBarVisibility.isHidden, isNull);
    });

    test('setVisibility throws NotInitializedError if not initialized', () {
      expect(
        () => StatusBarVisibility.setVisibility(isHidden: true),
        throwsA(isA<NotInitializedError>()),
      );
    });

    test(
      'init calls setEnabledSystemUIMode and sets default hidden state',
      () async {
        final log = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              log.add(call);
              return null;
            });

        OSPlatform.override(to: OSPlatform.linux);

        final result = await StatusBarVisibility.init();

        expect(result, isFalse);
        expect(StatusBarVisibility.isHidden, isTrue);
        expect(
          log.any(
            (call) =>
                call.method == 'SystemChrome.setEnabledSystemUIMode' &&
                call.arguments.toString().contains('edgeToEdge'),
          ),
          isTrue,
        );
      },
    );

    test('init respects setHidden: false', () async {
      OSPlatform.override(to: OSPlatform.linux);

      final result = await StatusBarVisibility.init(setHidden: false);

      expect(result, isFalse);
      expect(StatusBarVisibility.isHidden, isFalse);
    });

    group('Platform branches in setVisibility', () {
      setUp(() async {
        OSPlatform.override(to: OSPlatform.linux);
        await StatusBarVisibility.init();
      });

      test('returns true on Android', () async {
        OSPlatform.override(to: OSPlatform.android);

        expect(StatusBarVisibility.setVisibility(isHidden: true), isTrue);
        expect(StatusBarVisibility.isHidden, isTrue);

        expect(StatusBarVisibility.setVisibility(isHidden: false), isTrue);
        expect(StatusBarVisibility.isHidden, isFalse);

        await pumpEventQueue();
      });

      test('returns true on iOS', () async {
        OSPlatform.override(to: OSPlatform.iOS);

        expect(StatusBarVisibility.setVisibility(isHidden: true), isTrue);
        expect(StatusBarVisibility.isHidden, isTrue);

        expect(StatusBarVisibility.setVisibility(isHidden: false), isTrue);
        expect(StatusBarVisibility.isHidden, isFalse);

        await pumpEventQueue();
      });

      test('returns false on Fuchsia', () {
        OSPlatform.override(to: OSPlatform.fuchsia);
        expect(StatusBarVisibility.setVisibility(isHidden: true), isFalse);
      });

      test('returns false on Linux', () {
        OSPlatform.override(to: OSPlatform.linux);
        expect(StatusBarVisibility.setVisibility(isHidden: true), isFalse);
      });

      test('returns false on macOS', () {
        OSPlatform.override(to: OSPlatform.macOS);
        expect(StatusBarVisibility.setVisibility(isHidden: true), isFalse);
      });

      test('returns false on Web', () {
        OSPlatform.override(to: OSPlatform.web);
        expect(StatusBarVisibility.setVisibility(isHidden: true), isFalse);
      });

      test('returns false on Windows', () {
        OSPlatform.override(to: OSPlatform.windows);
        expect(StatusBarVisibility.setVisibility(isHidden: true), isFalse);
      });
    });

    test('reset clears internal state', () async {
      OSPlatform.override(to: OSPlatform.linux);

      await StatusBarVisibility.init();
      expect(StatusBarVisibility.isHidden, isNotNull);

      StatusBarVisibility.reset();
      expect(StatusBarVisibility.isHidden, isNull);
    });
  });
}
