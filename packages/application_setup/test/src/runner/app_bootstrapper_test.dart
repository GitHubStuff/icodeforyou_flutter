// test/src/runner/app_bootstrapper_test.dart

import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBootstrapper', () {
    test('ensureInitialized does not throw', () {
      const bootstrapper = AppBootstrapper();
      expect(bootstrapper.ensureInitialized, returnsNormally);
    });

    testWidgets('run calls runApp without throwing', (tester) async {
      const bootstrapper = AppBootstrapper();
      expect(
        () => bootstrapper.run(const SizedBox()),
        returnsNormally,
      );
    });
  });
}
