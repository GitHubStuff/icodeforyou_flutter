// packages/custom_widgets/test/src/stepper_theme/stepper_theme_test.dart
import 'package:custom_widgets/custom_widgets.dart' show StepperTheme;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StepperTheme', () {
    test('default values match constants', () {
      const theme = StepperTheme();

      expect(theme.crossFadeDuration, const Duration(milliseconds: 1250));
      expect(theme.buttonSize, 48);
      expect(theme.props, [theme.crossFadeDuration, theme.buttonSize]);
    });

    test('value equality via Equatable', () {
      const a = StepperTheme();
      const b = StepperTheme();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      const c = StepperTheme(buttonSize: 50);
      expect(a == c, isFalse);
    });

    test('copyWith replaces only provided fields', () {
      const original = StepperTheme(
        crossFadeDuration: Duration(seconds: 1),
        buttonSize: 60,
      );

      final copy1 = original.copyWith();
      expect(copy1.crossFadeDuration, original.crossFadeDuration);
      expect(copy1.buttonSize, original.buttonSize);

      final copy2 = original.copyWith(
        crossFadeDuration: const Duration(seconds: 2),
      );
      expect(copy2.crossFadeDuration, const Duration(seconds: 2));
      expect(copy2.buttonSize, 60);

      final copy3 = original.copyWith(buttonSize: 80);
      expect(copy3.crossFadeDuration, const Duration(seconds: 1));
      expect(copy3.buttonSize, 80);
    });

    test('lerp returns this when other is null', () {
      const theme = StepperTheme(
        crossFadeDuration: Duration(seconds: 1),
        buttonSize: 50,
      );

      final result = theme.lerp(null, 0.5);
      expect(result, same(theme));
    });

    test('lerp interpolates values correctly', () {
      const a = StepperTheme(
        crossFadeDuration: Duration(seconds: 1),
        buttonSize: 50,
      );
      const b = StepperTheme(
        crossFadeDuration: Duration(seconds: 3),
        buttonSize: 100,
      );

      final mid = a.lerp(b, 0.5);

      expect(mid.crossFadeDuration, const Duration(seconds: 2));
      expect(mid.buttonSize, 75);
    });

    testWidgets('StepperTheme.of returns default when not registered', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final theme = StepperTheme.of(context);
              expect(
                theme.crossFadeDuration,
                const Duration(milliseconds: 1250),
              );
              expect(theme.buttonSize, 48);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('StepperTheme.of returns registered extension', (tester) async {
      const customTheme = StepperTheme(
        crossFadeDuration: Duration(milliseconds: 800),
        buttonSize: 56,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              customTheme,
            ],
          ),
          home: Builder(
            builder: (context) {
              final theme = StepperTheme.of(context);
              expect(
                theme.crossFadeDuration,
                const Duration(milliseconds: 800),
              );
              expect(theme.buttonSize, 56);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
