// packages/app_navigation/test/src/destination/destination_manager_test.dart

import 'package:app_navigation/src/destination/destination_item.dart';
import 'package:app_navigation/src/destination/destination_manager.dart';
import 'package:app_navigation/src/destination/navigation_abstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _TestDestination implements NavigableDestinationAbstract {
  home(
    caption: 'Home',
    iconData: Icons.home,
  ),
  settings(
    caption: 'Settings',
    iconData: Icons.settings,
  ),
  profile(
    caption: 'Profile',
    iconData: Icons.person,
  ),
  about(
    caption: 'About',
    iconData: Icons.info,
  );

  const _TestDestination({
    required this.caption,
    required this.iconData,
  });

  @override
  final String caption;

  @override
  final IconData iconData;

  @override
  Widget Function() get viewBuilder => throw UnimplementedError();
}

void main() {
  group('DestinationManager', () {
    DestinationItem<_TestDestination> createItem(
      _TestDestination tag,
    ) {
      return DestinationItem<_TestDestination>(
        tag: tag,
        viewBuilder: () => const SizedBox.shrink(),
      );
    }

    group('assertions', () {
      test('succeeds with disjoint visible and overflow collections', () {
        expect(
          () => DestinationManager<_TestDestination>(
            visibleMenuItems: [
              createItem(_TestDestination.home),
              createItem(_TestDestination.settings),
            ],
            overflowMenuItems: [
              createItem(_TestDestination.profile),
            ],
          ),
          returnsNormally,
        );
      });

      test('defaults overflowMenuItems to empty list', () {
        final manager = DestinationManager<_TestDestination>(
          visibleMenuItems: [
            createItem(_TestDestination.home),
          ],
        );

        expect(manager.overflowMenuItems, isEmpty);
      });

      test(
        'throws AssertionError when visibleMenuItems has duplicate tags',
        () {
          expect(
            () => DestinationManager<_TestDestination>(
              visibleMenuItems: [
                createItem(_TestDestination.home),
                createItem(_TestDestination.home),
              ],
            ),
            throwsAssertionError,
          );
        },
      );

      test(
        'throws AssertionError when overflowMenuItems has duplicate tags',
        () {
          expect(
            () => DestinationManager<_TestDestination>(
              visibleMenuItems: [
                createItem(_TestDestination.home),
              ],
              overflowMenuItems: [
                createItem(_TestDestination.settings),
                createItem(_TestDestination.settings),
              ],
            ),
            throwsAssertionError,
          );
        },
      );

      test(
        'throws AssertionError when tags overlap across visible and overflow',
        () {
          expect(
            () => DestinationManager<_TestDestination>(
              visibleMenuItems: [
                createItem(_TestDestination.home),
                createItem(_TestDestination.settings),
              ],
              overflowMenuItems: [
                createItem(_TestDestination.home),
              ],
            ),
            throwsAssertionError,
          );
        },
      );
    });

    group('getItem', () {
      late DestinationItem<_TestDestination> visibleItem;
      late DestinationItem<_TestDestination> overflowItem;
      late DestinationManager<_TestDestination> manager;

      setUp(() {
        visibleItem = createItem(_TestDestination.home);
        overflowItem = createItem(_TestDestination.profile);
        manager = DestinationManager<_TestDestination>(
          visibleMenuItems: [visibleItem],
          overflowMenuItems: [overflowItem],
        );
      });

      test('returns matching item when present in visibleMenuItems', () {
        expect(
          manager.getItem(_TestDestination.home),
          equals(visibleItem),
        );
      });

      test('returns matching item when present in overflowMenuItems', () {
        expect(
          manager.getItem(_TestDestination.profile),
          equals(overflowItem),
        );
      });

      test(
        'throws StateError with tag name when tag is not present',
        () {
          expect(
            () => manager.getItem(_TestDestination.about),
            throwsA(
              isA<StateError>().having(
                (e) => e.message,
                'message',
                'No DestinationItem found for tag: "about".',
              ),
            ),
          );
        },
      );
    });

    group('overflowItem', () {
      late DestinationItem<_TestDestination> overflowItem;
      late DestinationManager<_TestDestination> manager;

      setUp(() {
        overflowItem = createItem(_TestDestination.profile);
        manager = DestinationManager<_TestDestination>(
          visibleMenuItems: [
            createItem(_TestDestination.home),
          ],
          overflowMenuItems: [overflowItem],
        );
      });

      test('returns matching item from overflowMenuItems', () {
        expect(
          manager.overflowItem(_TestDestination.profile),
          equals(overflowItem),
        );
      });

      test('throws StateError when tag exists in visible but not overflow', () {
        expect(
          () => manager.overflowItem(_TestDestination.home),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'No OverflowItem found for tag: "home".',
            ),
          ),
        );
      });

      test('throws StateError when tag is not present at all', () {
        expect(
          () => manager.overflowItem(_TestDestination.about),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'No OverflowItem found for tag: "about".',
            ),
          ),
        );
      });
    });

    group('visibleItem', () {
      late DestinationItem<_TestDestination> visibleItem;
      late DestinationManager<_TestDestination> manager;

      setUp(() {
        visibleItem = createItem(_TestDestination.home);
        manager = DestinationManager<_TestDestination>(
          visibleMenuItems: [visibleItem],
          overflowMenuItems: [
            createItem(_TestDestination.profile),
          ],
        );
      });

      test('returns matching item from visibleMenuItems', () {
        expect(
          manager.visibleItem(_TestDestination.home),
          equals(visibleItem),
        );
      });

      test('throws StateError when tag exists in overflow but not visible', () {
        expect(
          () => manager.visibleItem(_TestDestination.profile),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'No DestinationItem found for tag: "profile".',
            ),
          ),
        );
      });

      test('throws StateError when tag is not present at all', () {
        expect(
          () => manager.visibleItem(_TestDestination.about),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'No DestinationItem found for tag: "about".',
            ),
          ),
        );
      });
    });
  });
}
