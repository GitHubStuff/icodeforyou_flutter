// packages/dual_selection/test/src/single_selection_test.dart

import 'package:dual_selection/dual_selection.dart' show SingleSelection;
import 'package:dual_selection/src/defaults.dart' show Defaults;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const headerKey = Key('header');
  const bodyKey = Key('body');
  const borderColor = Color(0xFF123456);

  Widget buildSubject({
    double? cornerRadius,
    double? borderWidth,
    double? headerHeight,
    double? bodyHeight,
    double? width,
  }) {
    return Center(
      child: SingleSelection(
        first: const ColoredBox(key: headerKey, color: Color(0xFFFF0000)),
        firstChild: const ColoredBox(key: bodyKey, color: Color(0xFF00FF00)),
        borderColor: borderColor,
        cornerRadius: cornerRadius ?? Defaults.kCornerRadius,
        borderWidth: borderWidth ?? Defaults.kBorderWidth,
        headerHeight: headerHeight ?? Defaults.kHeaderHeight,
        bodyHeight: bodyHeight ?? Defaults.kBodyHeight,
        width: width ?? Defaults.kWidth,
      ),
    );
  }

  Finder inSubject(Finder matching) => find.descendant(
    of: find.byType(SingleSelection),
    matching: matching,
  );

  group('SingleSelection', () {
    group('construction', () {
      test('applies shared defaults', () {
        const subject = SingleSelection(
          first: SizedBox.shrink(),
          firstChild: SizedBox.shrink(),
          borderColor: borderColor,
        );

        expect(subject.cornerRadius, Defaults.kCornerRadius);
        expect(subject.borderWidth, Defaults.kBorderWidth);
        expect(subject.headerHeight, Defaults.kHeaderHeight);
        expect(subject.bodyHeight, Defaults.kBodyHeight);
        expect(subject.width, Defaults.kWidth);
      });

      test('throws when cornerRadius is negative', () {
        expect(
          () => SingleSelection(
            first: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            borderColor: borderColor,
            cornerRadius: -1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when borderWidth is negative', () {
        expect(
          () => SingleSelection(
            first: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            borderColor: borderColor,
            borderWidth: -1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when headerHeight is not positive', () {
        expect(
          () => SingleSelection(
            first: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            borderColor: borderColor,
            headerHeight: 0,
          ),
          throwsAssertionError,
        );
      });

      test('throws when bodyHeight is not positive', () {
        expect(
          () => SingleSelection(
            first: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            borderColor: borderColor,
            bodyHeight: 0,
          ),
          throwsAssertionError,
        );
      });

      test('throws when width is not positive', () {
        expect(
          () => SingleSelection(
            first: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            borderColor: borderColor,
            width: 0,
          ),
          throwsAssertionError,
        );
      });
    });

    group('layout', () {
      testWidgets('renders first and firstChild', (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byKey(headerKey), findsOneWidget);
        expect(find.byKey(bodyKey), findsOneWidget);
      });

      testWidgets('lays out first to width × headerHeight', (tester) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        expect(tester.getSize(find.byKey(headerKey)), const Size(200, 40));
      });

      testWidgets('lays out firstChild to width × bodyHeight', (tester) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        expect(tester.getSize(find.byKey(bodyKey)), const Size(200, 100));
      });

      testWidgets('places the body directly below the header', (tester) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        final headerRect = tester.getRect(find.byKey(headerKey));
        final bodyRect = tester.getRect(find.byKey(bodyKey));

        expect(bodyRect.top, headerRect.bottom);
        expect(bodyRect.left, headerRect.left);
      });

      testWidgets(
        'renders larger than the content area by 2 × borderWidth',
        (tester) async {
          await tester.pumpWidget(
            buildSubject(
              width: 200,
              headerHeight: 40,
              bodyHeight: 100,
              borderWidth: 5,
            ),
          );

          expect(
            tester.getSize(find.byType(SingleSelection)),
            const Size(210, 150),
          );
        },
      );
    });

    group('decoration', () {
      testWidgets('draws the border in borderColor at borderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(borderWidth: 5));

        final decoratedBox = tester.widget<DecoratedBox>(
          inSubject(find.byType(DecoratedBox)),
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(
          decoration.border,
          Border.all(color: borderColor, width: 5),
        );
      });

      testWidgets('rounds the outer border by cornerRadius', (tester) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 12));

        final decoratedBox = tester.widget<DecoratedBox>(
          inSubject(find.byType(DecoratedBox)),
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(decoration.borderRadius, BorderRadius.circular(12));
      });

      testWidgets('pads the content by borderWidth', (tester) async {
        await tester.pumpWidget(buildSubject(borderWidth: 5));

        final padding = tester.widget<Padding>(inSubject(find.byType(Padding)));

        expect(padding.padding, const EdgeInsets.all(5));
      });

      testWidgets('clips the content by cornerRadius minus borderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 12, borderWidth: 5));

        final clip = tester.widget<ClipRRect>(
          inSubject(find.byType(ClipRRect)),
        );

        expect(clip.borderRadius, BorderRadius.circular(7));
      });

      testWidgets('clamps the inner clip radius at zero', (tester) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 2, borderWidth: 5));

        final clip = tester.widget<ClipRRect>(
          inSubject(find.byType(ClipRRect)),
        );

        expect(clip.borderRadius, BorderRadius.zero);
      });
    });
  });
}
