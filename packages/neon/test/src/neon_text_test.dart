// packages/neon/test/src/neon_text_test.dart
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:neon/neon.dart';

void main() {
  group('NeonText', () {
    const label = 'OPEN';
    const base = Colors.green;

    Future<void> pump(WidgetTester tester, Widget child) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );
    }

    Text textOf(WidgetTester tester) {
      return tester.widget<Text>(find.byType(Text));
    }

    TextStyle styleOf(WidgetTester tester) {
      return textOf(tester).style!;
    }

    List<double> blurRadiiOf(WidgetTester tester) {
      return styleOf(
        tester,
      ).shadows!.map((shadow) => shadow.blurRadius).toList();
    }

    group('at distance 0', () {
      testWidgets('renders the given text', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(find.text(label), findsOneWidget);
      });

      testWidgets('uses the TiltNeon font family', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(styleOf(tester).fontFamily, 'TiltNeon');
      });

      testWidgets('applies the default font size', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(styleOf(tester).fontSize, 48);
      });

      testWidgets('applies a custom font size', (tester) async {
        await pump(tester, const NeonText(label, color: base, fontSize: 72));

        expect(styleOf(tester).fontSize, 72);
      });

      testWidgets(
        'fills the glyph with the derived tube core at full opacity',
        (tester) async {
          await pump(tester, const NeonText(label, color: base));

          expect(styleOf(tester).color, base.toNeonCore(tint: 0.45));
        },
      );

      testWidgets('passes a custom tint through to the core', (tester) async {
        await pump(tester, const NeonText(label, color: base, tint: 0.1));

        expect(styleOf(tester).color, base.toNeonCore(tint: 0.1));
      });

      testWidgets('builds four glow shadows at base radii', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(blurRadiiOf(tester), orderedEquals([4, 12, 24, 48]));
      });

      testWidgets('inner shadows use the derived accent at full opacity', (
        tester,
      ) async {
        await pump(tester, const NeonText(label, color: base));

        final shadows = styleOf(tester).shadows!;
        final accent = base.toNeonAccent();

        expect(shadows[0].color, accent);
        expect(shadows[1].color, accent);
        expect(shadows[2].color, accent);
      });

      testWidgets('outer shadow uses the derived accent at reduced opacity', (
        tester,
      ) async {
        await pump(tester, const NeonText(label, color: base));

        final outer = styleOf(tester).shadows!.last;

        expect(outer.color, base.toNeonAccent().withValues(alpha: 0.6));
      });

      testWidgets('does not wrap the sign in a defocus filter', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(find.byType(ImageFiltered), findsNothing);
      });

      testWidgets('omits package prefix by default', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(styleOf(tester).fontFamily, isNot(contains('/')));
      });

      testWidgets('prefixes font family with package when provided', (
        tester,
      ) async {
        await pump(
          tester,
          const NeonText(label, color: base, package: 'design_system'),
        );

        expect(styleOf(tester).fontFamily, 'packages/design_system/TiltNeon');
      });
    });

    group('line handling', () {
      testWidgets('defaults to unlimited lines', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(textOf(tester).maxLines, isNull);
      });

      testWidgets('forwards maxLines to the underlying Text', (tester) async {
        await pump(tester, const NeonText(label, color: base, maxLines: 2));

        expect(textOf(tester).maxLines, 2);
      });

      testWidgets('defaults overflow to ellipsis', (tester) async {
        await pump(tester, const NeonText(label, color: base));

        expect(textOf(tester).overflow, TextOverflow.ellipsis);
      });

      testWidgets('forwards a custom overflow', (tester) async {
        await pump(
          tester,
          const NeonText(label, color: base, overflow: TextOverflow.fade),
        );

        expect(textOf(tester).overflow, TextOverflow.fade);
      });

      testWidgets('truncates long text to maxLines', (tester) async {
        const long = 'OPEN TWENTY FOUR HOURS A DAY SEVEN DAYS A WEEK';

        await pump(
          tester,
          const SizedBox(
            width: 120,
            child: NeonText(long, color: base, maxLines: 1),
          ),
        );

        final renderText = tester.renderObject<RenderParagraph>(
          find.byType(RichText),
        );

        expect(renderText.didExceedMaxLines, isTrue);
      });
    });

    group('at distance 1', () {
      testWidgets('triples the glow radii', (tester) async {
        await pump(tester, const NeonText(label, color: base, distance: 1));

        expect(blurRadiiOf(tester), orderedEquals([12, 36, 72, 144]));
      });

      testWidgets('fades the tube core to half opacity', (tester) async {
        await pump(tester, const NeonText(label, color: base, distance: 1));

        expect(styleOf(tester).color?.a, closeTo(0.5, 0.01));
      });

      testWidgets('wraps the sign in a defocus filter', (tester) async {
        await pump(tester, const NeonText(label, color: base, distance: 1));

        expect(find.byType(ImageFiltered), findsOneWidget);
      });

      testWidgets('still renders the text inside the filter', (tester) async {
        await pump(tester, const NeonText(label, color: base, distance: 1));

        expect(
          find.descendant(
            of: find.byType(ImageFiltered),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      });
    });

    group('at distance 0.5', () {
      testWidgets('scales the glow radii proportionally', (tester) async {
        await pump(
          tester,
          const NeonText(label, color: base, distance: 0.5),
        );

        expect(blurRadiiOf(tester), orderedEquals([8, 24, 48, 96]));
      });

      testWidgets('fades the tube core proportionally', (tester) async {
        await pump(
          tester,
          const NeonText(label, color: base, distance: 0.5),
        );

        expect(styleOf(tester).color?.a, closeTo(0.75, 0.01));
      });

      testWidgets('wraps the sign in a defocus filter', (tester) async {
        await pump(
          tester,
          const NeonText(label, color: base, distance: 0.5),
        );

        expect(find.byType(ImageFiltered), findsOneWidget);
      });
    });

    group('asserts', () {
      test('rejects tint below 0', () {
        expect(
          () => NeonText(label, color: base, tint: -0.1),
          throwsAssertionError,
        );
      });

      test('rejects tint above 1', () {
        expect(
          () => NeonText(label, color: base, tint: 1.1),
          throwsAssertionError,
        );
      });

      test('accepts tint boundaries', () {
        expect(() => const NeonText(label, color: base, tint: 0), returnsNormally);
        expect(() => const NeonText(label, color: base, tint: 1), returnsNormally);
      });

      test('rejects distance below 0', () {
        expect(
          () => NeonText(label, color: base, distance: -0.1),
          throwsAssertionError,
        );
      });

      test('rejects distance above 1', () {
        expect(
          () => NeonText(label, color: base, distance: 1.1),
          throwsAssertionError,
        );
      });

      test('accepts distance boundaries', () {
        expect(
          () => const NeonText(label, color: base, distance: 0),
          returnsNormally,
        );
        expect(
          () => const NeonText(label, color: base, distance: 1),
          returnsNormally,
        );
      });
    });
  });
}
