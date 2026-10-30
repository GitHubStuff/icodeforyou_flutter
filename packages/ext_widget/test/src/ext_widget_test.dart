// packages/ext_widget/test/src/ext_widget_test.dart

import 'package:ext_widget/src/ext_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const childKey = Key('test_child');
  // ignore: sized_box_for_whitespace
  final baseWidget = Container(key: childKey, width: 50, height: 50);

  group('ExtWidget.hide', () {
    testWidgets('wraps child in Opacity(opacity: 0.0) when true', (
      tester,
    ) async {
      await tester.pumpWidget(baseWidget.hide(true));

      final opacityFinder = find.byType(Opacity);
      expect(opacityFinder, findsOneWidget);

      final opacityWidget = tester.widget<Opacity>(opacityFinder);
      expect(opacityWidget.opacity, 0.0);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('returns original widget unchanged when false', (tester) async {
      await tester.pumpWidget(baseWidget.hide(false));

      expect(find.byType(Opacity), findsNothing);
      expect(find.byKey(childKey), findsOneWidget);
    });
  });

  group('ExtWidget.remove', () {
    testWidgets('wraps in SizedBox.shrink with child when true', (
      tester,
    ) async {
      await tester.pumpWidget(baseWidget.remove(true));

      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('returns original widget unchanged when false', (tester) async {
      await tester.pumpWidget(baseWidget.remove(false));

      expect(find.byKey(childKey), findsOneWidget);
    });
  });

  group('ExtWidget.removeAnimated', () {
    testWidgets('renders AnimatedSize with default arguments', (tester) async {
      await tester.pumpWidget(baseWidget.removeAnimated(false));

      final animatedSizeFinder = find.byType(AnimatedSize);
      expect(animatedSizeFinder, findsOneWidget);

      final animatedSize = tester.widget<AnimatedSize>(animatedSizeFinder);
      expect(animatedSize.duration, const Duration(milliseconds: 300));
      expect(animatedSize.curve, Curves.easeInOut);
      expect(animatedSize.alignment, Alignment.topCenter);
      expect(animatedSize.clipBehavior, Clip.hardEdge);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets(
      'renders SizedBox.shrink inside AnimatedSize when shouldRemove is true',
      (tester) async {
        await tester.pumpWidget(
          baseWidget.removeAnimated(
            true,
            duration: const Duration(seconds: 1),
            curve: Curves.linear,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
          ),
        );

        final animatedSize = tester.widget<AnimatedSize>(
          find.byType(AnimatedSize),
        );
        expect(animatedSize.duration, const Duration(seconds: 1));
        expect(animatedSize.curve, Curves.linear);
        expect(animatedSize.alignment, Alignment.center);
        expect(animatedSize.clipBehavior, Clip.antiAlias);

        expect(find.byKey(childKey), findsNothing);
        expect(animatedSize.child, isA<SizedBox>());
        final innerBox = animatedSize.child as SizedBox;
        expect(innerBox.width, 0.0);
        expect(innerBox.height, 0.0);
      },
    );
  });

  group('ExtWidget.squareFit', () {
    testWidgets('wraps in SizedBox.square and FittedBox with defaults', (
      tester,
    ) async {
      await tester.pumpWidget(baseWidget.squareFit(side: 100));

      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, 100);
      expect(sizedBox.height, 100);

      final fittedBoxFinder = find.byType(FittedBox);
      expect(fittedBoxFinder, findsOneWidget);
      final fittedBox = tester.widget<FittedBox>(fittedBoxFinder);
      expect(fittedBox.fit, BoxFit.fill);
      expect(fittedBox.alignment, Alignment.center);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('passes custom alignment to FittedBox', (tester) async {
      await tester.pumpWidget(
        baseWidget.squareFit(side: 80, alignment: Alignment.bottomRight),
      );

      final fittedBox = tester.widget<FittedBox>(find.byType(FittedBox));
      expect(fittedBox.alignment, Alignment.bottomRight);
    });
  });

  group('ExtWidget.withBackground', () {
    testWidgets('wraps in DecoratedBox with specified background color', (
      tester,
    ) async {
      const color = Color(0xFFFF0000);
      await tester.pumpWidget(baseWidget.withBackground(color));

      final decoratedBoxFinder = find.byType(DecoratedBox);
      expect(decoratedBoxFinder, findsOneWidget);

      final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);
      expect(decoratedBox.decoration, isA<BoxDecoration>());
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.color, color);
      expect(find.byKey(childKey), findsOneWidget);
    });
  });

  group('ExtWidget.withBorder', () {
    testWidgets('applies default border properties', (tester) async {
      const color = Color(0xFF00FF00);
      await tester.pumpWidget(baseWidget.withBorder(color));

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.top.color, color);
      expect(border.top.width, 1.5);
      expect(border.top.style, BorderStyle.solid);
      expect(decoration.borderRadius, BorderRadius.circular(0));
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('applies custom border width, radius, and style', (
      tester,
    ) async {
      const color = Color(0xFF0000FF);
      await tester.pumpWidget(
        baseWidget.withBorder(
          color,
          width: 4,
          radius: 12,
          style: BorderStyle.none,
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.color, color);
      expect(border.top.width, 4.0);
      expect(border.top.style, BorderStyle.none);
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
  });

  group('ExtWidget.withOpacity', () {
    testWidgets('applies valid opacity', (tester) async {
      await tester.pumpWidget(baseWidget.withOpacity(0.5));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
      expect(find.byKey(childKey), findsOneWidget);
    });

    test('throws ArgumentError when opacity < 0.0', () {
      expect(
        () => baseWidget.withOpacity(-0.1),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'opacity')
              .having((e) => e.invalidValue, 'invalidValue', -0.1),
        ),
      );
    });

    test('throws ArgumentError when opacity > 1.0', () {
      expect(
        () => baseWidget.withOpacity(1.01),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'opacity')
              .having((e) => e.invalidValue, 'invalidValue', 1.01),
        ),
      );
    });
  });

  group('ExtWidget padding extensions', () {
    testWidgets('withPadding defaults all insets to 0.0', (tester) async {
      await tester.pumpWidget(baseWidget.withPadding());

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, EdgeInsets.zero);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('withPadding applies explicit individual insets', (
      tester,
    ) async {
      await tester.pumpWidget(
        baseWidget.withPadding(left: 1, top: 2, right: 3, bottom: 4),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.only(left: 1, top: 2, right: 3, bottom: 4),
      );
    });

    testWidgets('withPaddingAll applies uniform insets', (tester) async {
      await tester.pumpWidget(baseWidget.withPaddingAll(16));

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(16));
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('withSymmetricPadding defaults to 0.0', (tester) async {
      await tester.pumpWidget(baseWidget.withSymmetricPadding());

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, EdgeInsets.zero);
    });

    testWidgets('withSymmetricPadding applies horizontal and vertical insets', (
      tester,
    ) async {
      await tester.pumpWidget(
        baseWidget.withSymmetricPadding(horizontal: 12, vertical: 8),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });
  });

  group('ExtWidget wrap extensions', () {
    testWidgets('withWrap defaults color to transparent and insets to 0.0', (
      tester,
    ) async {
      await tester.pumpWidget(baseWidget.withWrap());

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, const Color(0x00000000));

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, EdgeInsets.zero);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('withWrap applies custom insets and background color', (
      tester,
    ) async {
      const color = Color(0xFF123456);
      await tester.pumpWidget(
        baseWidget.withWrap(
          left: 5,
          right: 6,
          top: 7,
          bottom: 8,
          color: color,
        ),
      );

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, color);

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.only(left: 5, top: 7, right: 6, bottom: 8),
      );
    });

    testWidgets(
      'withWrapAll applies uniform insets with default transparent color',
      (tester) async {
        await tester.pumpWidget(baseWidget.withWrapAll(10));

        final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
        expect(coloredBox.color, const Color(0x00000000));

        final padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, const EdgeInsets.all(10));
        expect(find.byKey(childKey), findsOneWidget);
      },
    );

    testWidgets('withWrapAll applies uniform insets with specified color', (
      tester,
    ) async {
      const color = Color(0xFFABCDEF);
      await tester.pumpWidget(baseWidget.withWrapAll(14, color: color));

      final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(coloredBox.color, color);

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(14));
    });
  });
}
