// test/src/contextual_reveal/src/theme/contextual_reveal_theme_test.dart

import 'package:animated_widgets/src/contextual_reveal/src/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextualRevealTheme', () {
    test('dark factory yields a ContextualRevealDark', () {
      expect(ContextualRevealTheme.dark(), isA<ContextualRevealDark>());
    });

    test('light factory yields a ContextualRevealLight', () {
      expect(ContextualRevealTheme.light(), isA<ContextualRevealLight>());
    });

    group('of', () {
      // Resolves the theme from a context sitting under a bare [Theme], whose
      // [ThemeData] is passed through without the lerping a [MaterialApp]
      // animated theme would apply.
      Future<ContextualRevealTheme> resolve(
        WidgetTester tester,
        ThemeData data,
      ) async {
        late ContextualRevealTheme resolved;
        await tester.pumpWidget(
          Theme(
            data: data,
            child: Builder(
              builder: (context) {
                resolved = ContextualRevealTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        );
        return resolved;
      }

      testWidgets('returns the registered extension when one is present', (
        tester,
      ) async {
        // A distinctive barrier colour identifies this exact extension,
        // distinguishing it from either brightness fallback.
        final registered = const ContextualRevealDark().copyWith(
          barrierColor: const Color(0xFF010203),
        );

        final resolved = await resolve(
          tester,
          ThemeData(extensions: <ThemeExtension<dynamic>>[registered]),
        );

        expect(resolved, isA<ContextualRevealDark>());
        expect(resolved.barrierColor, const Color(0xFF010203));
      });

      testWidgets(
        'falls back to dark when no extension and brightness is dark',
        (tester) async {
          final resolved = await resolve(
            tester,
            ThemeData(brightness: Brightness.dark),
          );

          expect(resolved, isA<ContextualRevealDark>());
        },
      );

      testWidgets(
        'falls back to light when no extension and brightness is light',
        (tester) async {
          final resolved = await resolve(
            tester,
            ThemeData(brightness: Brightness.light),
          );

          expect(resolved, isA<ContextualRevealLight>());
        },
      );
    });
  });
}
