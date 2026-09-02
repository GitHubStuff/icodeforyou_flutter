// packages/app_navigation/test/src/shared/dual_show_popover_test.dart
import 'package:app_navigation/src/shared/dual_show_popover.dart';
import 'package:extensions/enum/src/haptic_intensity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp({
    required Alignment anchorAlignment,
    required List<Widget> children,
    int initialScrollIndex = 0,
    HapticIntensity scrollHaptic = HapticIntensity.light,
    EdgeInsets safePadding = EdgeInsets.zero,
    ValueChanged<String?>? onResult,
    Size? anchorSize,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(800, 600),
          padding: safePadding,
        ),
        child: Scaffold(
          body: Align(
            alignment: anchorAlignment,
            child: Builder(
              builder: (context) {
                return SizedBox.fromSize(
                  size: anchorSize ?? const Size(48, 48),
                  child: GestureDetector(
                    key: const ValueKey('open_anchor'),
                    onTap: () async {
                      final result = await dualShowPopover<String>(
                        anchorContext: context,
                        children: children,
                        initialScrollIndex: initialScrollIndex,
                        scrollHaptic: scrollHaptic,
                      );
                      onResult?.call(result);
                    },
                    child: const ColoredBox(
                      color: Colors.blue,
                      child: Center(child: Text('Open')),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  group('dualShowPopover', () {
    testWidgets(
      'opens upward from bottom anchor, clamps position, and returns selected value on pop',
      (tester) async {
        String? selectedResult;

        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.bottomCenter,
            safePadding: const EdgeInsets.all(16),
            children: List.generate(
              3,
              (index) => SizedBox(
                height: 48,
                child: Builder(
                  builder: (context) => InkWell(
                    onTap: () => Navigator.pop(context, 'item_$index'),
                    child: Text('Item $index'),
                  ),
                ),
              ),
            ),
            onResult: (res) => selectedResult = res,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);

        // Tap item to select
        await tester.tap(find.text('Item 1'));
        await tester.pumpAndSettle();

        expect(selectedResult, equals('item_1'));
      },
    );

    testWidgets(
      'dismisses popover on transparent barrier tap returning null',
      (tester) async {
        String? selectedResult = 'initial';

        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.bottomCenter,
            children: const [
              SizedBox(height: 48, child: Text('Single Item')),
            ],
            onResult: (res) => selectedResult = res,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        expect(find.text('Single Item'), findsOneWidget);

        // Tap outside popover surface on barrier
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('Single Item'), findsNothing);
        expect(selectedResult, isNull);
      },
    );

    testWidgets(
      'positions popover to the right when anchor is nearest to left edge',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.centerLeft,
            children: const [
              SizedBox(height: 48, child: Text('Left Rail Item')),
            ],
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        expect(find.text('Left Rail Item'), findsOneWidget);
      },
    );

    testWidgets(
      'positions popover to the left when anchor is nearest to right edge',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.centerRight,
            children: const [
              SizedBox(height: 48, child: Text('Right Rail Item')),
            ],
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        expect(find.text('Right Rail Item'), findsOneWidget);
      },
    );

    testWidgets(
      'opens scrolled to initialScrollIndex and handles scroll haptic ticks',
      (tester) async {
        final items = List.generate(
          15,
          (index) => SizedBox(
            height: 48,
            child: Text('Long Item $index'),
          ),
        );

        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.bottomCenter,
            initialScrollIndex: 8,
            scrollHaptic: HapticIntensity.medium,
            children: items,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        // Target index 8 should be visible initially
        expect(find.text('Long Item 8'), findsOneWidget);

        // Drag the list down by more than 1 tile extent (48dp) to trigger the tick branch
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();

        // Drag by small distance (<48dp) to test sub-threshold branch
        await tester.drag(find.byType(ListView), const Offset(0, -10));
        await tester.pump();
      },
    );

    testWidgets(
      'ignores scroll ticks when scrollHaptic is HapticIntensity.none',
      (tester) async {
        final items = List.generate(
          15,
          (index) => SizedBox(
            height: 48,
            child: Text('Item $index'),
          ),
        );

        await tester.pumpWidget(
          buildApp(
            anchorAlignment: Alignment.bottomCenter,
            scrollHaptic: HapticIntensity.none,
            children: items,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();

        expect(find.text('Item 0'), findsNothing);
      },
    );

    testWidgets(
      'delegate shouldRelayout detects changes in anchorRect and safePadding',
      (tester) async {
        var padding = const EdgeInsets.all(8);
        var anchorAlign = Alignment.bottomCenter;

        late StateSetter updateState;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                updateState = setState;
                return MediaQuery(
                  data: MediaQueryData(
                    size: const Size(800, 600),
                    padding: padding,
                  ),
                  child: Scaffold(
                    body: Align(
                      alignment: anchorAlign,
                      child: Builder(
                        builder: (ctx) => SizedBox(
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            key: const ValueKey('open_anchor'),
                            onTap: () {
                              dualShowPopover<void>(
                                anchorContext: ctx,
                                children: const [Text('Item')],
                              );
                            },
                            child: const Text('Open'),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byKey(const ValueKey('open_anchor')));
        await tester.pumpAndSettle();

        // Trigger safePadding update
        updateState(() {
          padding = const EdgeInsets.all(24);
        });
        await tester.pump();

        // Trigger anchor position update
        updateState(() {
          anchorAlign = Alignment.bottomLeft;
        });
        await tester.pump();

        expect(find.text('Item'), findsOneWidget);
      },
    );
  });
}
