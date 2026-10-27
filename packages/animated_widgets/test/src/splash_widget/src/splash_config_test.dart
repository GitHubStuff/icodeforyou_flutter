// packages/animated_widgets/test/src/splash_widget/src/splash_config_test.dart
import 'package:animated_widgets/src/splash_widget/src/splash_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashConfig', () {
    test('defaults every field', () {
      const config = SplashConfig();

      expect(config.splashDuration, const Duration(seconds: 4));
      expect(config.timeoutDuration, const Duration(seconds: 30));
      expect(config.crossfadeDuration, const Duration(milliseconds: 200));
      expect(config.timeoutText, 'Time Out');
      expect(config.backgroundTaskFailedText, 'Background task failed');
    });

    test('honours every supplied field', () {
      const config = SplashConfig(
        splashDuration: Duration(seconds: 1),
        timeoutDuration: Duration(seconds: 2),
        crossfadeDuration: Duration(milliseconds: 50),
        timeoutText: 'Took too long',
        backgroundTaskFailedText: 'Something broke',
      );

      expect(config.splashDuration, const Duration(seconds: 1));
      expect(config.timeoutDuration, const Duration(seconds: 2));
      expect(config.crossfadeDuration, const Duration(milliseconds: 50));
      expect(config.timeoutText, 'Took too long');
      expect(config.backgroundTaskFailedText, 'Something broke');
    });
  });
}
