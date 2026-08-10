// test/build_context/build_context_ext_test.dart

import 'package:extensions/build_context/build_context_ext.dart'
    show BuildContextExt;
import 'package:extensions/enum/src/window_size_category.dart'
    show WindowSizeCategory;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildContextExt.isKeyboardOpen', () {
    testWidgets('is true when the bottom view inset is non-zero', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 100),
          ),
          child: Builder(
            builder: (innerContext) {
              context = innerContext;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(context.isKeyboardOpen, isTrue);
    });

    testWidgets('is false when there is no bottom view inset', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Builder(
            builder: (innerContext) {
              context = innerContext;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(context.isKeyboardOpen, isFalse);
    });
  });

  group('BuildContextExt.hideKeyboard', () {
    testWidgets('unfocuses a focused text field', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: node),
                Builder(
                  builder: (innerContext) {
                    context = innerContext;
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // No primary-focus change requested yet: must not throw.
      context.hideKeyboard();
      await tester.pump();

      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);

      context.hideKeyboard();
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });
  });

  group('BuildContextExt.widgetBounds', () {
    testWidgets('returns the semantic bounds of the render box', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 50,
            child: Builder(
              builder: (innerContext) {
                context = innerContext;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      expect(context.widgetBounds(), const Rect.fromLTWH(0, 0, 100, 50));
    });

    testWidgets('returns null when the render object is not a RenderBox', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverLayoutBuilder(
                builder: (innerContext, constraints) {
                  context = innerContext;
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      );
      expect(context.widgetBounds(), isNull);
    });
  });

  group('BuildContextExt.widgetGlobalOffset', () {
    testWidgets('returns the global offset of the render-box origin', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            height: 50,
            child: Builder(
              builder: (innerContext) {
                context = innerContext;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      // Test surface is 800x600, so a centered 100x50 box sits at (350, 275).
      expect(context.widgetGlobalOffset(), const Offset(350, 275));
    });

    testWidgets('returns null when the render object is not a RenderBox', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverLayoutBuilder(
                builder: (innerContext, constraints) {
                  context = innerContext;
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      );
      expect(context.widgetGlobalOffset(), isNull);
    });
  });

  group('BuildContextExt.windowSizeCategory', () {
    Future<WindowSizeCategory> resolve(
      WidgetTester tester,
      double width,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Builder(
            builder: (innerContext) {
              context = innerContext;
              return const SizedBox();
            },
          ),
        ),
      );
      return context.windowSizeCategory;
    }

    testWidgets('resolves each Material breakpoint range', (tester) async {
      expect(await resolve(tester, 400), WindowSizeCategory.compact);
      expect(await resolve(tester, 599), WindowSizeCategory.compact);
      expect(await resolve(tester, 600), WindowSizeCategory.medium);
      expect(await resolve(tester, 839), WindowSizeCategory.medium);
      expect(await resolve(tester, 840), WindowSizeCategory.expanded);
      expect(await resolve(tester, 1199), WindowSizeCategory.expanded);
      expect(await resolve(tester, 1200), WindowSizeCategory.large);
      expect(await resolve(tester, 1599), WindowSizeCategory.large);
      expect(await resolve(tester, 1600), WindowSizeCategory.extraLarge);
      expect(await resolve(tester, 4000), WindowSizeCategory.extraLarge);
    });
  });
}
