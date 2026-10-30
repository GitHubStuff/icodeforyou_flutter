// packages/ext_buildcontext/test/src/ext_buildcontext_test.dart

import 'package:ext_buildcontext/ext_buildcontext.dart' show ExtBuildContext;
import 'package:ext_buildcontext/window_size_category.dart'
    show WindowSizeCategory;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtBuildContext', () {
    testWidgets('orientation returns MediaQuery.orientationOf', (tester) async {
      late Orientation capturedOrientation;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              capturedOrientation = context.orientation;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedOrientation, Orientation.landscape);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 800)),
          child: Builder(
            builder: (context) {
              capturedOrientation = context.orientation;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedOrientation, Orientation.portrait);
    });

    testWidgets('isKeyboardOpen returns true when bottom viewInsets > 0', (
      tester,
    ) async {
      late bool keyboardOpen;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 250)),
          child: Builder(
            builder: (context) {
              keyboardOpen = context.isKeyboardOpen;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(keyboardOpen, isTrue);
    });

    testWidgets('isKeyboardOpen returns false when bottom viewInsets is 0', (
      tester,
    ) async {
      late bool keyboardOpen;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.zero),
          child: Builder(
            builder: (context) {
              keyboardOpen = context.isKeyboardOpen;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(keyboardOpen, isFalse);
    });

    group('hideKeyboard', () {
      testWidgets(
        'calls unfocus when focus scope does not have primary focus',
        (tester) async {
          final focusNode = FocusNode();
          late BuildContext capturedContext;

          await tester.pumpWidget(
            WidgetsApp(
              color: const Color(0xFFFFFFFF),
              builder: (context, _) {
                return FocusScope(
                  child: Builder(
                    builder: (innerContext) {
                      capturedContext = innerContext;
                      return Focus(
                        focusNode: focusNode,
                        child: const SizedBox(),
                      );
                    },
                  ),
                );
              },
            ),
          );

          // Request focus on the child node so FocusScope has focus, but NOT primary focus.
          focusNode.requestFocus();
          await tester.pump();

          final focusScope = FocusScope.of(capturedContext);
          expect(focusScope.hasFocus, isTrue);
          expect(focusScope.hasPrimaryFocus, isFalse);

          capturedContext.hideKeyboard();
          await tester.pump();

          expect(focusScope.hasFocus, isFalse);
          focusNode.dispose();
        },
      );

      testWidgets('does nothing when focus scope has primary focus', (
        tester,
      ) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          WidgetsApp(
            color: const Color(0xFFFFFFFF),
            builder: (context, _) {
              return FocusScope(
                autofocus: true,
                child: Builder(
                  builder: (innerContext) {
                    capturedContext = innerContext;
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        );

        final focusScope = FocusScope.of(capturedContext);
        expect(focusScope.hasPrimaryFocus, isTrue);

        // Should not throw and should remain focused
        capturedContext.hideKeyboard();
        await tester.pump();

        expect(focusScope.hasPrimaryFocus, isTrue);
      });
    });

    group('widgetBounds and widgetGlobalOffset', () {
      testWidgets(
        'returns semanticBounds and global offset for valid RenderBox',
        (tester) async {
          late BuildContext capturedContext;

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
                children: [
                  Positioned(
                    left: 40,
                    top: 60,
                    child: SizedBox(
                      width: 120,
                      height: 80,
                      child: Builder(
                        builder: (context) {
                          capturedContext = context;
                          return const ColoredBox(color: Color(0xFF000000));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          expect(
            capturedContext.widgetBounds(),
            equals(const Rect.fromLTWH(0, 0, 120, 80)),
          );
          expect(
            capturedContext.widgetGlobalOffset(),
            equals(const Offset(40, 60)),
          );
        },
      );

      testWidgets(
        'returns null when findRenderObject does not return a RenderBox',
        (tester) async {
          // rootElement attaches to RenderView, which is a RenderObject but not a RenderBox.
          final rootElement = tester.binding.rootElement!;

          expect(rootElement.widgetBounds(), isNull);
          expect(rootElement.widgetGlobalOffset(), isNull);
        },
      );
    });

    group('windowSizeCategory', () {
      testWidgets('resolves matching WindowSizeCategory across all values', (
        tester,
      ) async {
        for (final category in WindowSizeCategory.values) {
          // Determine a target test width safely within this category's range
          final double targetWidth;
          if (category.upperBound.isInfinite) {
            targetWidth = 5000.0;
          } else {
            targetWidth = category.upperBound - 1.0;
          }

          late WindowSizeCategory resolvedCategory;

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(size: Size(targetWidth, 800)),
              child: Builder(
                builder: (context) {
                  resolvedCategory = context.windowSizeCategory;
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(
            resolvedCategory,
            equals(category),
            reason: 'Width $targetWidth should resolve to category $category',
          );
        }
      });
    });
  });
}
