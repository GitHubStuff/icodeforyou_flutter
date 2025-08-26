// widget_ext_test.dart

import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetExt', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const Text('Test Widget');
    });

    group('hide', () {
      test('returns original widget when shouldHide is false', () {
        final result = testWidget.hide(false);
        expect(result, equals(testWidget));
      });

      test('returns widget with 0.0 opacity when shouldHide is true', () {
        final result = testWidget.hide(true);
        expect(result, isA<Opacity>());

        final opacityWidget = result as Opacity;
        expect(opacityWidget.opacity, equals(0.0));
        expect(opacityWidget.child, equals(testWidget));
      });
    });

    group('remove', () {
      test('returns original widget when shouldRemove is false', () {
        final result = testWidget.remove(false);
        expect(result, equals(testWidget));
      });

      test('returns SizedBox.shrink when shouldRemove is true', () {
        final result = testWidget.remove(true);
        expect(result, isA<SizedBox>());

        final sizedBox = result as SizedBox;
        expect(sizedBox.width, equals(0.0));
        expect(sizedBox.height, equals(0.0));
      });
    });

    group('withBackground', () {
      test('wraps widget with DecoratedBox containing background color', () {
        const testColor = Colors.red;
        final result = testWidget.withBackground(color: testColor);

        expect(result, isA<DecoratedBox>());

        final decoratedBox = result as DecoratedBox;
        expect(decoratedBox.child, equals(testWidget));
        expect(decoratedBox.decoration, isA<BoxDecoration>());

        final boxDecoration = decoratedBox.decoration as BoxDecoration;
        expect(boxDecoration.color, equals(testColor));
      });

      test('works with different colors', () {
        const testColor = Colors.blue;
        final result = testWidget.withBackground(color: testColor);

        final decoratedBox = result as DecoratedBox;
        final boxDecoration = decoratedBox.decoration as BoxDecoration;
        expect(boxDecoration.color, equals(testColor));
      });
    });

    group('withBorder', () {
      test('wraps widget with Container containing border decoration', () {
        const testColor = Colors.black;
        final result = testWidget.withBorder(color: testColor);

        expect(result, isA<Container>());

        final container = result as Container;
        expect(container.child, equals(testWidget));
        expect(container.decoration, isA<BoxDecoration>());

        final boxDecoration = container.decoration as BoxDecoration;
        expect(boxDecoration.border, isA<Border>());
        expect(boxDecoration.borderRadius, isA<BorderRadius>());
      });

      test('applies default values correctly', () {
        const testColor = Colors.black;
        final result = testWidget.withBorder(color: testColor);

        final container = result as Container;
        final boxDecoration = container.decoration as BoxDecoration;
        final border = boxDecoration.border as Border;

        expect(border.top.color, equals(testColor));
        expect(border.top.width, equals(1.5)); // default width
        expect(border.top.style, equals(BorderStyle.solid)); // default style

        final borderRadius = boxDecoration.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, equals(0.0)); // default radius
      });

      test('applies custom width and radius', () {
        const testColor = Colors.red;
        const testWidth = 3.0;
        const testRadius = 12.0;

        final result = testWidget.withBorder(
          color: testColor,
          width: testWidth,
          radius: testRadius,
        );

        final container = result as Container;
        final boxDecoration = container.decoration as BoxDecoration;
        final border = boxDecoration.border as Border;
        final borderRadius = boxDecoration.borderRadius as BorderRadius;

        expect(border.top.width, equals(testWidth));
        expect(borderRadius.topLeft.x, equals(testRadius));
      });

      test('applies custom border style', () {
        const testColor = Colors.green;
        const testStyle = BorderStyle.none;

        final result = testWidget.withBorder(
          color: testColor,
          style: testStyle,
        );

        final container = result as Container;
        final boxDecoration = container.decoration as BoxDecoration;
        final border = boxDecoration.border as Border;

        expect(border.top.style, equals(testStyle));
      });

      test('throws ArgumentError for negative width', () {
        expect(
          () => testWidget.withBorder(color: Colors.black, width: -1.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'width')
                .having(
                  (e) => e.message,
                  'message',
                  'Border width must be non-negative',
                ),
          ),
        );
      });

      test('throws ArgumentError for negative radius', () {
        expect(
          () => testWidget.withBorder(color: Colors.black, radius: -5.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'radius')
                .having(
                  (e) => e.message,
                  'message',
                  'Border radius must be non-negative',
                ),
          ),
        );
      });

      test('accepts zero width and radius', () {
        final result = testWidget.withBorder(
          color: Colors.black,
          width: 0.0,
          radius: 0.0,
        );

        expect(result, isA<Container>());
      });
    });

    group('withOpacity', () {
      test('wraps widget with Opacity widget', () {
        const opacityValue = 0.5;
        final result = testWidget.withOpacity(opacityValue);

        expect(result, isA<Opacity>());

        final opacity = result as Opacity;
        expect(opacity.child, equals(testWidget));
        expect(opacity.opacity, equals(opacityValue));
      });

      test('accepts boundary values 0.0 and 1.0', () {
        final result1 = testWidget.withOpacity(0.0);
        final result2 = testWidget.withOpacity(1.0);

        expect((result1 as Opacity).opacity, equals(0.0));
        expect((result2 as Opacity).opacity, equals(1.0));
      });

      test('throws ArgumentError for values below 0.0', () {
        expect(
          () => testWidget.withOpacity(-0.1),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'opacityValue')
                .having(
                  (e) => e.message,
                  'message',
                  'Opacity must be between 0.0 and 1.0',
                ),
          ),
        );
      });

      test('throws ArgumentError for values above 1.0', () {
        expect(
          () => testWidget.withOpacity(1.1),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'opacityValue')
                .having(
                  (e) => e.message,
                  'message',
                  'Opacity must be between 0.0 and 1.0',
                ),
          ),
        );
      });
    });

    group('withPaddingAll', () {
      test('wraps widget with Padding widget using EdgeInsets.all', () {
        const paddingValue = 16.0;
        final result = testWidget.withPaddingAll(paddingValue);

        expect(result, isA<Padding>());

        final padding = result as Padding;
        expect(padding.child, equals(testWidget));
        expect(padding.padding, equals(EdgeInsets.all(paddingValue)));
      });

      test('accepts zero padding', () {
        final result = testWidget.withPaddingAll(0.0);
        final padding = result as Padding;
        expect(padding.padding, equals(EdgeInsets.all(0.0)));
      });

      test('throws ArgumentError for negative padding', () {
        expect(
          () => testWidget.withPaddingAll(-5.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'paddingValue')
                .having(
                  (e) => e.message,
                  'message',
                  'Padding must be non-negative',
                ),
          ),
        );
      });
    });

    group('withPaddingOnly', () {
      test('wraps widget with Padding using EdgeInsets.only with defaults', () {
        final result = testWidget.withPaddingOnly();

        expect(result, isA<Padding>());

        final padding = result as Padding;
        expect(padding.child, equals(testWidget));
        expect(
          padding.padding,
          equals(
            const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
          ),
        );
      });

      test('applies custom padding values', () {
        const left = 10.0;
        const top = 15.0;
        const right = 20.0;
        const bottom = 25.0;

        final result = testWidget.withPaddingOnly(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        );

        final padding = result as Padding;
        expect(
          padding.padding,
          equals(
            const EdgeInsets.only(
              left: left,
              top: top,
              right: right,
              bottom: bottom,
            ),
          ),
        );
      });

      test('applies partial padding values', () {
        const left = 8.0;
        const top = 12.0;

        final result = testWidget.withPaddingOnly(left: left, top: top);

        final padding = result as Padding;
        expect(
          padding.padding,
          equals(
            const EdgeInsets.only(
              left: left,
              top: top,
              right: 0.0,
              bottom: 0.0,
            ),
          ),
        );
      });

      test('throws ArgumentError for negative left padding', () {
        expect(
          () => testWidget.withPaddingOnly(left: -1.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'left')
                .having(
                  (e) => e.message,
                  'message',
                  'Left padding must be non-negative',
                ),
          ),
        );
      });

      test('throws ArgumentError for negative top padding', () {
        expect(
          () => testWidget.withPaddingOnly(top: -1.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'top')
                .having(
                  (e) => e.message,
                  'message',
                  'Top padding must be non-negative',
                ),
          ),
        );
      });

      test('throws ArgumentError for negative right padding', () {
        expect(
          () => testWidget.withPaddingOnly(right: -1.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'right')
                .having(
                  (e) => e.message,
                  'message',
                  'Right padding must be non-negative',
                ),
          ),
        );
      });

      test('throws ArgumentError for negative bottom padding', () {
        expect(
          () => testWidget.withPaddingOnly(bottom: -1.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'bottom')
                .having(
                  (e) => e.message,
                  'message',
                  'Bottom padding must be non-negative',
                ),
          ),
        );
      });
    });

    group('withPaddingSymmetric', () {
      test(
        'wraps widget with Padding using EdgeInsets.symmetric with defaults',
        () {
          final result = testWidget.withPaddingSymmetric();

          expect(result, isA<Padding>());

          final padding = result as Padding;
          expect(padding.child, equals(testWidget));
          expect(
            padding.padding,
            equals(const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0)),
          );
        },
      );

      test('applies custom horizontal and vertical padding', () {
        const horizontal = 24.0;
        const vertical = 12.0;

        final result = testWidget.withPaddingSymmetric(
          horizontal: horizontal,
          vertical: vertical,
        );

        final padding = result as Padding;
        expect(
          padding.padding,
          equals(
            const EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: vertical,
            ),
          ),
        );
      });

      test('applies only horizontal padding', () {
        const horizontal = 16.0;

        final result = testWidget.withPaddingSymmetric(horizontal: horizontal);

        final padding = result as Padding;
        expect(
          padding.padding,
          equals(
            const EdgeInsets.symmetric(horizontal: horizontal, vertical: 0.0),
          ),
        );
      });

      test('applies only vertical padding', () {
        const vertical = 20.0;

        final result = testWidget.withPaddingSymmetric(vertical: vertical);

        final padding = result as Padding;
        expect(
          padding.padding,
          equals(
            const EdgeInsets.symmetric(horizontal: 0.0, vertical: vertical),
          ),
        );
      });

      test('throws ArgumentError for negative horizontal padding', () {
        expect(
          () => testWidget.withPaddingSymmetric(horizontal: -5.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'horizontal')
                .having(
                  (e) => e.message,
                  'message',
                  'Horizontal padding must be non-negative',
                ),
          ),
        );
      });

      test('throws ArgumentError for negative vertical padding', () {
        expect(
          () => testWidget.withPaddingSymmetric(vertical: -3.0),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'vertical')
                .having(
                  (e) => e.message,
                  'message',
                  'Vertical padding must be non-negative',
                ),
          ),
        );
      });
    });

    group('chaining methods', () {
      test('allows chaining multiple extension methods', () {
        final result = testWidget
            .withPaddingAll(16.0)
            .withBackground(color: Colors.blue)
            .withBorder(color: Colors.black, width: 2.0, radius: 8.0)
            .withOpacity(0.8);

        expect(result, isA<Opacity>());

        final opacity = result as Opacity;
        expect(opacity.opacity, equals(0.8));
        expect(
          opacity.child,
          isA<Container>(),
        ); // The border creates a Container

        final container = opacity.child as Container;
        expect(
          container.child,
          isA<DecoratedBox>(),
        ); // The background creates a DecoratedBox

        final decoratedBox = container.child as DecoratedBox;
        expect(
          decoratedBox.child,
          isA<Padding>(),
        ); // The padding creates a Padding

        final padding = decoratedBox.child as Padding;
        expect(
          padding.child,
          equals(testWidget),
        ); // Original widget at the core
      });

      test('allows conditional chaining with hide and remove', () {
        final result1 = testWidget
            .withPaddingAll(8.0)
            .hide(false)
            .remove(false);

        expect(result1, isA<Padding>());

        final result2 = testWidget.withPaddingAll(8.0).hide(true).remove(false);

        expect(result2, isA<Opacity>());

        final result3 = testWidget.withPaddingAll(8.0).hide(false).remove(true);

        expect(result3, isA<SizedBox>());
      });
    });
  });
}
