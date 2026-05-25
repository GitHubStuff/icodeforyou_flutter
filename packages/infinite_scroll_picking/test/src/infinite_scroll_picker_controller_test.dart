// test/src/infinite_scroll_picker_controller_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('InfiniteScrollPickerController', () {
    group('when unattached', () {
      test('currentIndex returns null', () {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        expect(controller.currentIndex, isNull);
      });

      test('reset() throws an AssertionError', () {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        expect(() => controller.reset(), throwsA(isA<AssertionError>()));
      });

      test('jumpToIndex() throws an AssertionError', () {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        expect(
          () => controller.jumpToIndex(0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('animateToIndex() throws an AssertionError', () {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        expect(
          () => controller.animateToIndex(0),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('when attached via a picker', () {
      Future<void> pumpPicker(
        WidgetTester tester, {
        required InfiniteScrollPickerController controller,
        List<String> items = const ['a', 'b', 'c', 'd'],
        int startingIndex = 0,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: InfiniteScrollPicker<String, String>(
                  controller: controller,
                  config: InfiniteScrollPickerConfig<String, String>(
                    items: items,
                    pickerId: 'p',
                    startingIndex: startingIndex,
                  ),
                  label: const Text('label'),
                  itemBuilder: (item, isSelected) => Text(item),
                  onItemSelected: (_, _) {},
                ),
              ),
            ),
          ),
        );
      }

      testWidgets('currentIndex reports the picker startingIndex', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(
          tester,
          controller: controller,
          startingIndex: 2,
        );

        expect(controller.currentIndex, 2);
      });

      testWidgets('reset() with null duration snaps and returns a future', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(
          tester,
          controller: controller,
          startingIndex: 1,
        );

        controller.jumpToIndex(3);
        await tester.pumpAndSettle();

        final future = controller.reset();
        await tester.pumpAndSettle();
        await future;

        expect(controller.currentIndex, 1);
      });

      testWidgets('reset() with a duration animates to startingIndex', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(
          tester,
          controller: controller,
          startingIndex: 0,
        );

        controller.jumpToIndex(2);
        await tester.pumpAndSettle();

        final future = controller.reset(
          duration: const Duration(milliseconds: 50),
        );
        await tester.pumpAndSettle();
        await future;

        expect(controller.currentIndex, 0);
      });

      testWidgets('jumpToIndex updates currentIndex synchronously', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(tester, controller: controller);

        controller.jumpToIndex(2);
        await tester.pumpAndSettle();

        expect(controller.currentIndex, 2);
      });

      testWidgets('jumpToIndex wraps via modulo for out-of-range values', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(tester, controller: controller);

        // items.length is 4, so 5 should wrap to 1.
        controller.jumpToIndex(5);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 1);

        // -1 should wrap to length - 1 = 3 (Dart `%` is non-negative).
        controller.jumpToIndex(-1);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 3);
      });

      testWidgets('animateToIndex completes at the requested index', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        await pumpPicker(tester, controller: controller);

        final future = controller.animateToIndex(
          2,
          duration: const Duration(milliseconds: 50),
        );
        await tester.pumpAndSettle();
        await future;

        expect(controller.currentIndex, 2);
      });

      testWidgets('addListener fires when the selection commits', (
        tester,
      ) async {
        final controller = InfiniteScrollPickerController();
        addTearDown(controller.dispose);

        var notifyCount = 0;
        controller.addListener(() => notifyCount += 1);

        await pumpPicker(tester, controller: controller);

        controller.jumpToIndex(2);
        await tester.pumpAndSettle();

        expect(notifyCount, greaterThan(0));
      });

      testWidgets(
        'attaching the same controller to two pickers throws an assert',
        (tester) async {
          final controller = InfiniteScrollPickerController();
          addTearDown(controller.dispose);

          // Mount the first picker on its own and let it settle. The
          // controller is now cleanly attached to picker #1.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: InfiniteScrollPicker<String, String>(
                  controller: controller,
                  config: InfiniteScrollPickerConfig<String, String>(
                    items: const ['a', 'b'],
                    pickerId: 'p1',
                    startingIndex: 0,
                  ),
                  label: const Text('one'),
                  itemBuilder: (item, isSelected) => Text(item),
                  onItemSelected: (_, _) {},
                ),
              ),
            ),
          );
          expect(controller.currentIndex, 0);

          // Now add a SECOND picker bound to the same controller. The
          // second picker's initState will hit the
          //   `_binding == null` assert in _attach()
          // during this pump.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    InfiniteScrollPicker<String, String>(
                      controller: controller,
                      config: InfiniteScrollPickerConfig<String, String>(
                        items: const ['a', 'b'],
                        pickerId: 'p1',
                        startingIndex: 0,
                      ),
                      label: const Text('one'),
                      itemBuilder: (item, isSelected) => Text(item),
                      onItemSelected: (_, _) {},
                    ),
                    InfiniteScrollPicker<String, String>(
                      controller: controller,
                      config: InfiniteScrollPickerConfig<String, String>(
                        items: const ['a', 'b'],
                        pickerId: 'p2',
                        startingIndex: 0,
                      ),
                      label: const Text('two'),
                      itemBuilder: (item, isSelected) => Text(item),
                      onItemSelected: (_, _) {},
                    ),
                  ],
                ),
              ),
            ),
          );

          // takeException returns the FIRST exception captured during the
          // pump. Walk through anything else by repeatedly draining until
          // we find our AssertionError carrying the controller's message.
          Object? captured = tester.takeException();
          var foundOurs = false;
          while (captured != null) {
            if (captured is AssertionError &&
                captured.message.toString().contains('already attached')) {
              foundOurs = true;
              break;
            }
            captured = tester.takeException();
          }
          expect(
            foundOurs,
            isTrue,
            reason:
                'Expected the controller’s "already attached to a picker" '
                'assertion to surface during the second pump.',
          );

          // Tear the broken tree down to an empty widget so the test
          // teardown phase doesn't cascade through a half-mounted second
          // picker. Drain any further exceptions the unmount produces.
          await tester.pumpWidget(const SizedBox());
          while (tester.takeException() != null) {}
        },
      );
    });
  });
}
