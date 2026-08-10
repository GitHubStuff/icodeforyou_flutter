// test/widget/widget_ext_test.dart

import 'package:extensions/widget/widget_ext.dart' show WidgetExt;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const child = SizedBox(width: 10, height: 10);

  group('WidgetExt.hide', () {
    test('wraps in zero opacity when shouldHide is true', () {
      final result = child.hide(true);
      expect(result, isA<Opacity>());
      expect((result as Opacity).opacity, 0);
      expect(result.child, same(child));
    });

    test('returns the widget unchanged when shouldHide is false', () {
      expect(child.hide(false), same(child));
    });
  });

  group('WidgetExt.remove', () {
    test('wraps in a shrunken SizedBox when shouldRemove is true', () {
      final result = child.remove(true);
      expect(result, isA<SizedBox>());
      expect((result as SizedBox).width, 0);
      expect(result.height, 0);
      expect(result.child, same(child));
    });

    test('returns the widget unchanged when shouldRemove is false', () {
      expect(child.remove(false), same(child));
    });
  });

  group('WidgetExt.withBackground', () {
    test('wraps in a DecoratedBox carrying the color', () {
      final result = child.withBackground(color: Colors.amber);
      expect(result, isA<DecoratedBox>());
      final decoration =
          (result as DecoratedBox).decoration as BoxDecoration;
      expect(decoration.color, Colors.amber);
      expect(result.child, same(child));
    });
  });

  group('WidgetExt.withBorder', () {
    test('wraps in a Container with border and radius', () {
      final result = child.withBorder(
        color: Colors.black,
        width: 2,
        radius: 8,
      );
      expect(result, isA<Container>());
      final decoration = (result as Container).decoration! as BoxDecoration;
      expect(decoration.border, Border.all(color: Colors.black, width: 2));
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    test('applies default width, radius, and style', () {
      final result = child.withBorder(color: Colors.black);
      final decoration = (result as Container).decoration! as BoxDecoration;
      expect(decoration.border, Border.all(color: Colors.black, width: 1.5));
      expect(decoration.borderRadius, BorderRadius.zero);
    });

    test('throws ArgumentError for a negative width', () {
      expect(
        () => child.withBorder(color: Colors.black, width: -1),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a negative radius', () {
      expect(
        () => child.withBorder(color: Colors.black, radius: -1),
        throwsArgumentError,
      );
    });
  });

  group('WidgetExt.withOpacity', () {
    test('wraps in an Opacity with the given value', () {
      final result = child.withOpacity(0.7);
      expect(result, isA<Opacity>());
      expect((result as Opacity).opacity, 0.7);
      expect(result.child, same(child));
    });

    test('throws ArgumentError below 0.0', () {
      expect(() => child.withOpacity(-0.1), throwsArgumentError);
    });

    test('throws ArgumentError above 1.0', () {
      expect(() => child.withOpacity(1.1), throwsArgumentError);
    });
  });

  group('WidgetExt.withPaddingAll', () {
    test('wraps in uniform padding', () {
      final result = child.withPaddingAll(16);
      expect(result, isA<Padding>());
      expect((result as Padding).padding, const EdgeInsets.all(16));
      expect(result.child, same(child));
    });

    test('throws ArgumentError for a negative value', () {
      expect(() => child.withPaddingAll(-1), throwsArgumentError);
    });
  });

  group('WidgetExt.withPaddingOnly', () {
    test('wraps in per-side padding', () {
      final result = child.withPaddingOnly(
        left: 1,
        top: 2,
        right: 3,
        bottom: 4,
      );
      expect(
        (result as Padding).padding,
        const EdgeInsets.only(left: 1, top: 2, right: 3, bottom: 4),
      );
    });

    test('throws ArgumentError for a negative left value', () {
      expect(() => child.withPaddingOnly(left: -1), throwsArgumentError);
    });

    test('throws ArgumentError for a negative top value', () {
      expect(() => child.withPaddingOnly(top: -1), throwsArgumentError);
    });

    test('throws ArgumentError for a negative right value', () {
      expect(() => child.withPaddingOnly(right: -1), throwsArgumentError);
    });

    test('throws ArgumentError for a negative bottom value', () {
      expect(() => child.withPaddingOnly(bottom: -1), throwsArgumentError);
    });
  });

  group('WidgetExt.withPaddingSymmetric', () {
    test('wraps in symmetric padding', () {
      final result = child.withPaddingSymmetric(horizontal: 24, vertical: 12);
      expect(
        (result as Padding).padding,
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
    });

    test('throws ArgumentError for a negative horizontal value', () {
      expect(
        () => child.withPaddingSymmetric(horizontal: -1),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a negative vertical value', () {
      expect(
        () => child.withPaddingSymmetric(vertical: -1),
        throwsArgumentError,
      );
    });
  });
}
