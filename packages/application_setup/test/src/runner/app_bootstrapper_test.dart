// test/src/runner/app_bootstrapper_test.dart

import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBootstrapper', () {
    test('ensureInitialized does not throw', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      expect(
        () => const AppBootstrapper().ensureInitialized(),
        returnsNormally,
      );
    });
  });
}
