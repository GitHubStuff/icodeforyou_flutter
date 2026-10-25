// packages/{{name.snakeCase()}}/test/src/{{name.snakeCase()}}_border_test.dart
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';

void main() {
  const base = Colors.green;
  const child = Text('OPEN');

  Future<void> pump(WidgetTester tester, Widget widget) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: widget)),
      ),
    );
  }

  BoxDecoration decorationOf(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox));

    return box.decoration as BoxDecoration;
  }

  group('{{name.titleCase()}}Border', () {
    testWidgets('renders the child', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('draws the tube in the derived core colour', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final border = decorationOf(tester).border! as Border;

      expect(border.top.color, base.to{{name.titleCase()}}Core(tint: 0.45));
    });

    testWidgets('applies the default tube width', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final border = decorationOf(tester).border! as Border;

      expect(border.top.width, 3);
    });

    testWidgets('applies a custom tube width', (tester) async {
      await pump(
        tester,
        const {{name.titleCase()}}Border(color: base, width: 5, child: child),
      );

      final border = decorationOf(tester).border! as Border;

      expect(border.top.width, 5);
    });

    testWidgets('applies the default corner radius', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      expect(decorationOf(tester).borderRadius, BorderRadius.circular(12));
    });

    testWidgets('applies a custom corner radius', (tester) async {
      await pump(
        tester,
        const {{name.titleCase()}}Border(color: base, radius: 0, child: child),
      );

      expect(decorationOf(tester).borderRadius, BorderRadius.zero);
    });

    testWidgets('applies the default padding', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final padding = tester.widget<Padding>(find.byType(Padding).first);

      expect(padding.padding, const EdgeInsets.all(16));
    });

    testWidgets('applies custom padding', (tester) async {
      await pump(
        tester,
        const {{name.titleCase()}}Border(color: base, padding: EdgeInsets.zero, child: child),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);

      expect(padding.padding, EdgeInsets.zero);
    });

    testWidgets('builds four layered glow shadows', (tester) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final shadows = decorationOf(tester).boxShadow;

      expect(shadows, hasLength(4));
      expect(
        shadows?.map((shadow) => shadow.blurRadius),
        orderedEquals([4, 12, 24, 48]),
      );
    });

    testWidgets('inner shadows use the derived accent at full opacity', (
      tester,
    ) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final shadows = decorationOf(tester).boxShadow!;
      final accent = base.to{{name.titleCase()}}Accent();

      expect(shadows[0].color, accent);
      expect(shadows[1].color, accent);
      expect(shadows[2].color, accent);
    });

    testWidgets('outer shadow uses the derived accent at reduced opacity', (
      tester,
    ) async {
      await pump(tester, const {{name.titleCase()}}Border(color: base, child: child));

      final outer = decorationOf(tester).boxShadow!.last;

      expect(outer.color, base.to{{name.titleCase()}}Accent().withValues(alpha: 0.6));
    });

    group('asserts', () {
      test('rejects zero width', () {
        expect(
          () => {{name.titleCase()}}Border(color: base, width: 0, child: child),
          throwsAssertionError,
        );
      });

      test('rejects negative width', () {
        expect(
          () => {{name.titleCase()}}Border(color: base, width: -1, child: child),
          throwsAssertionError,
        );
      });

      test('rejects negative radius', () {
        expect(
          () => {{name.titleCase()}}Border(color: base, radius: -1, child: child),
          throwsAssertionError,
        );
      });
    });
  });

  group('with{{name.titleCase()}}Border', () {
    testWidgets('wraps the receiver in a {{name.titleCase()}}Border', (tester) async {
      await pump(tester, child.with{{name.titleCase()}}Border(color: base));

      expect(find.byType({{name.titleCase()}}Border), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('forwards colour', (tester) async {
      await pump(tester, child.with{{name.titleCase()}}Border(color: base));

      final border = tester.widget<{{name.titleCase()}}Border>(find.byType({{name.titleCase()}}Border));

      expect(border.color, base);
    });

    testWidgets('forwards defaults', (tester) async {
      await pump(tester, child.with{{name.titleCase()}}Border(color: base));

      final border = tester.widget<{{name.titleCase()}}Border>(find.byType({{name.titleCase()}}Border));

      expect(border.width, 3);
      expect(border.radius, 12);
      expect(border.padding, const EdgeInsets.all(16));
    });

    testWidgets('forwards custom values', (tester) async {
      await pump(
        tester,
        child.with{{name.titleCase()}}Border(
          color: base,
          width: 6,
          radius: 24,
          padding: const EdgeInsets.all(8),
        ),
      );

      final border = tester.widget<{{name.titleCase()}}Border>(find.byType({{name.titleCase()}}Border));

      expect(border.width, 6);
      expect(border.radius, 24);
      expect(border.padding, const EdgeInsets.all(8));
    });

    testWidgets('forwards key', (tester) async {
      const key = Key('sign');

      await pump(tester, child.with{{name.titleCase()}}Border(color: base, key: key));

      expect(find.byKey(key), findsOneWidget);
    });
  });
}
