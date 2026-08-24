// packages/splash_framework/test/src/splash_screen_args_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_framework/src/splash_screen_args.dart';

void main() {
  group('SplashScreenArgs', () {
    test('can be instantiated and retains its fields', () {
      const duration = Duration(milliseconds: 500);
      final tasks = <Future<void> Function()>[Future<void>.value];
      const child = SizedBox();
      void onComplete() {}
      void onError(Object error) {}

      final args = SplashScreenArgs(
        duration: duration,
        tasks: tasks,
        child: child,
        onComplete: onComplete,
        onError: onError,
      );

      expect(args.duration, duration);
      expect(args.tasks, tasks);
      expect(args.child, child);
      expect(args.onComplete, onComplete);
      expect(args.onError, onError);
    });
  });
}
