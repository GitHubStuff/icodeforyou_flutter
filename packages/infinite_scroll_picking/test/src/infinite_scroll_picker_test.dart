// test/src/infinite_scroll_picker_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('InfiniteScrollPicker', () {
    InfiniteScrollPickerConfig<String, String> makeConfig({
      List<String> items = const ['a', 'b', 'c', 'd'],
      String pickerId = 'p',
      int startingIndex = 0,
      InfiniteScrollWheelConfig wheelConfig = const InfiniteScrollWheelConfig(),
    }) {
      return InfiniteScrollPickerConfig<String, String>(
        items: items,
        pickerId: pickerId,
        startingIndex: startingIndex,
        wheelConfig: wheelConfig,
      );
    }

    Widget hostPicker({
      required InfiniteScrollPickerConfig<String, String> config,
      InfiniteScrollPickerController? controller,
      void Function(String, String)? onItemSelected,
      Widget label = const Text('label'),
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: InfiniteScrollPicker<String, String>(
              controller: controller,
              config: config,
              label: label,
              itemBuilder: (item, isSelected) => Text(
                item,
                style: TextStyle(
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              onItemSelected: onItemSelected ?? (_, _) {},
            ),
          ),
        ),
      );
    }

    group('build', () {
      testWidgets('renders label and items', (tester) async {
        await tester.pumpWidget(
          hostPicker(config: makeConfig(), label: const Text('hello')),
        );

        expect(find.text('hello'), findsOneWidget);
        expect(find.text('a'), findsWidgets);
      });

      testWidgets('reports the starting item as selected on first build', (
        tester,
      ) async {
        await tester.pumpWidget(
          hostPicker(config: makeConfig(startingIndex: 2)),
        );

        // The currently centered item (index 2 -> 'c') should be rendered with
        // bold weight by the itemBuilder.
        final boldFinder = find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.data == 'c' &&
              w.style?.fontWeight == FontWeight.bold,
        );
        expect(boldFinder, findsWidgets);
      });
    });

    group('controller ownership', () {
      testWidgets('creates and disposes its own controller when none given', (
        tester,
      ) async {
        await tester.pumpWidget(hostPicker(config: makeConfig()));

        // Removing the picker forces dispose of the internally-owned
        // controller. If lifecycle is wrong, the framework throws.
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(tester.takeException(), isNull);
      });

      testWidgets('does NOT dispose an externally-owned controller', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();

        await tester.pumpWidget(
          hostPicker(config: makeConfig(), controller: controller),
        );

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(tester.takeException(), isNull);

        // Still usable post-disposal of the picker -> means we did not
        // dispose it. After detach, currentIndex is null.
        expect(controller.currentIndex, isNull);
        controller.dispose();
      });
    });

    group('didUpdateWidget', () {
      testWidgets('swaps controller when the consumer changes the instance', (
        tester,
      ) async {
        final controllerA = InfiniteScrollPickerController();
        final controllerB = InfiniteScrollPickerController();
        addTearDown(() {
          controllerA.dispose();
          controllerB.dispose();
        });

        await tester.pumpWidget(
          hostPicker(config: makeConfig(), controller: controllerA),
        );
        expect(controllerA.currentIndex, 0);
        expect(controllerB.currentIndex, isNull);

        await tester.pumpWidget(
          hostPicker(config: makeConfig(), controller: controllerB),
        );
        expect(controllerA.currentIndex, isNull);
        expect(controllerB.currentIndex, 0);
      });

      testWidgets(
        'is a no-op when the same config (and items list identity) reused',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);
          final config = makeConfig(startingIndex: 1);

          await tester.pumpWidget(
            hostPicker(config: config, controller: controller),
          );

          // Move the wheel to index 3.
          controller.jumpToIndex(3);
          await tester.pumpAndSettle();
          expect(controller.currentIndex, 3);

          // Pump again with the SAME config; identity fast-path should
          // skip the rebuild and the selection should NOT reset.
          await tester.pumpWidget(
            hostPicker(config: config, controller: controller),
          );
          expect(controller.currentIndex, 3);
        },
      );

      testWidgets(
        'is a no-op when items differ by reference but are equal in content',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            hostPicker(
              config: makeConfig(items: const ['a', 'b', 'c']),
              controller: controller,
            ),
          );
          controller.jumpToIndex(2);
          await tester.pumpAndSettle();
          expect(controller.currentIndex, 2);

          // New list, same content — _listEquals returns true so no reset.
          await tester.pumpWidget(
            hostPicker(
              config: makeConfig(items: <String>['a', 'b', 'c']),
              controller: controller,
            ),
          );
          expect(controller.currentIndex, 2);
        },
      );

      testWidgets('rebuilds and resets when items length changes', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(items: const ['a', 'b', 'c', 'd']),
            controller: controller,
          ),
        );
        controller.jumpToIndex(3);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 3);

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(items: const ['x', 'y']),
            controller: controller,
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 0);
      });

      testWidgets(
        'rebuilds and resets when items differ in content at same length',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            hostPicker(
              config: makeConfig(items: const ['a', 'b', 'c']),
              controller: controller,
            ),
          );
          controller.jumpToIndex(2);
          await tester.pumpAndSettle();

          await tester.pumpWidget(
            hostPicker(
              config: makeConfig(items: const ['a', 'b', 'd']),
              controller: controller,
            ),
          );
          await tester.pumpAndSettle();
          expect(controller.currentIndex, 0);
        },
      );

      testWidgets('rebuilds and resets when startingIndex changes', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(startingIndex: 0),
            controller: controller,
          ),
        );
        controller.jumpToIndex(2);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 2);

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(startingIndex: 3),
            controller: controller,
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 3);
      });

      testWidgets(
        'cancels a pending debounce timer when items change mid-scroll',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);
          final selections = <String>[];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: InfiniteScrollPicker<String, String>(
                  controller: controller,
                  config: makeConfig(
                    wheelConfig: const InfiniteScrollWheelConfig(
                      selectionDebounce: Duration(milliseconds: 200),
                    ),
                  ),
                  label: const Text('label'),
                  itemBuilder: (item, isSelected) => Text(item),
                  onItemSelected: (_, item) => selections.add(item),
                ),
              ),
            ),
          );

          // Trigger a selection; debounced callback is now pending.
          controller.jumpToIndex(2);
          await tester.pump();

          // Replace items before the debounce fires — this should cancel the
          // pending timer in didUpdateWidget.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: InfiniteScrollPicker<String, String>(
                  controller: controller,
                  config: makeConfig(
                    items: const ['x', 'y', 'z'],
                    wheelConfig: const InfiniteScrollWheelConfig(
                      selectionDebounce: Duration(milliseconds: 200),
                    ),
                  ),
                  label: const Text('label'),
                  itemBuilder: (item, isSelected) => Text(item),
                  onItemSelected: (_, item) => selections.add(item),
                ),
              ),
            ),
          );

          // Advance past the original debounce window. The cancelled timer
          // should NOT fire a 'c' selection from the old items list.
          await tester.pump(const Duration(milliseconds: 250));
          expect(selections.contains('c'), isFalse);
        },
      );
    });

    group('selection callbacks', () {
      testWidgets('fires onItemSelected synchronously when not debounced', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);
        final selections = <String>[];

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(),
            controller: controller,
            onItemSelected: (_, item) => selections.add(item),
          ),
        );

        controller.jumpToIndex(2);
        await tester.pumpAndSettle();

        expect(selections, contains('c'));
      });

      testWidgets('debounces onItemSelected when configured', (tester) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);
        final selections = <String>[];

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(
              wheelConfig: const InfiniteScrollWheelConfig(
                selectionDebounce: Duration(milliseconds: 100),
              ),
            ),
            controller: controller,
            onItemSelected: (_, item) => selections.add(item),
          ),
        );

        controller.jumpToIndex(1);
        await tester.pump(); // schedules debounce
        expect(selections, isEmpty);

        // Quickly schedule another selection — should reset the timer.
        controller.jumpToIndex(2);
        await tester.pump();
        expect(selections, isEmpty);

        await tester.pump(const Duration(milliseconds: 150));
        expect(selections, ['c']);
      });

      testWidgets('does not fire when the selection is unchanged', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);
        final selections = <String>[];

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(),
            controller: controller,
            onItemSelected: (_, item) => selections.add(item),
          ),
        );

        // Jumping to index 0 (the current selection) should NOT fire.
        controller.jumpToIndex(0);
        await tester.pumpAndSettle();

        expect(selections, isEmpty);
      });

      testWidgets(
        'does not commit the debounced selection if the picker unmounts',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);
          final selections = <String>[];

          await tester.pumpWidget(
            hostPicker(
              config: makeConfig(
                wheelConfig: const InfiniteScrollWheelConfig(
                  selectionDebounce: Duration(milliseconds: 100),
                ),
              ),
              controller: controller,
              onItemSelected: (_, item) => selections.add(item),
            ),
          );

          controller.jumpToIndex(1);
          await tester.pump();

          // Tear down before the debounce fires. dispose() cancels the timer,
          // so even if it didn't, the `mounted` guard would block the call.
          await tester.pumpWidget(const MaterialApp(home: SizedBox()));
          await tester.pump(const Duration(milliseconds: 200));

          expect(selections, isEmpty);
        },
      );
    });

    group('shortest-wrap targeting', () {
      // The internal _targetOffset chooses the shortest direction around the
      // wheel. Driving it through animateToIndex covers all three branches:
      //   1. delta within (-len/2, len/2)  — direct
      //   2. delta > len/2                  — wrap backward
      //   3. delta < -len/2                 — wrap forward
      testWidgets('takes the shortest path around the wheel', (tester) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          hostPicker(
            config: makeConfig(items: const ['a', 'b', 'c', 'd', 'e']),
            controller: controller,
          ),
        );

        // Drive the animation, then pump frames to advance the test clock —
        // do NOT await the future first; without frames the animation can
        // never progress and the await deadlocks.
        Future<void> drive(int target) async {
          final f = controller.animateToIndex(
            target,
            duration: const Duration(milliseconds: 50),
          );
          await tester.pumpAndSettle();
          await f;
        }

        // From 0 -> 4 with length 5: forward delta = 4, backward delta = -1.
        // Should pick the backward wrap (shortest).
        await drive(4);
        expect(controller.currentIndex, 4);

        // From 4 -> 0: forward delta = -4 wraps to +1; should land cleanly.
        await drive(0);
        expect(controller.currentIndex, 0);

        // From 0 -> 2: middle case, direct path.
        await drive(2);
        expect(controller.currentIndex, 2);
      });
    });
  });
}
