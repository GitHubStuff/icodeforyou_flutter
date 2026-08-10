// packages/custom_widgets/test/src/crash_screen/crash_screen_args_test.dart

import 'package:custom_widgets/custom_widgets.dart' show CrashScreenArgs;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashScreenArgs', () {
    test('holds the required error and defaults optionals to null', () {
      const args = CrashScreenArgs(error: 'boom');

      expect(args.error, 'boom');
      expect(args.stackTrace, isNull);
      expect(args.resumePath, isNull);
    });

    test('holds all supplied values', () {
      final trace = StackTrace.fromString('trace-line');
      final args = CrashScreenArgs(
        error: 'boom',
        stackTrace: trace,
        resumePath: '/home',
      );

      expect(args.error, 'boom');
      expect(args.stackTrace, same(trace));
      expect(args.resumePath, '/home');
    });
  });
}
