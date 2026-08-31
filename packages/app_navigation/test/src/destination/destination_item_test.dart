// packages/app_navigation/test/src/destination/destination_item_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:app_navigation/src/destination/destination_item.dart'
    show DestinationItem;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _TestDestination implements NavigableDestinationAbstract {
  home(
    caption: 'Home Default',
    iconData: Icons.home,
  ),
  settings(
    caption: 'Settings Default',
    iconData: Icons.settings,
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
  group('DestinationItem', () {
    test(
      'falls back to tag properties when iconData and caption are omitted',
      () {
        const tag = _TestDestination.home;
        final item = DestinationItem<_TestDestination>(
          tag: tag,
          viewBuilder: () => const SizedBox.shrink(),
        );

        expect(item.tag, equals(tag));
        expect(item.iconData, equals(tag.iconData));
        expect(item.caption, equals(tag.caption));
      },
    );

    test('overrides tag properties when explicit values are passed', () {
      const tag = _TestDestination.settings;
      const customIcon = Icons.tune;
      const customCaption = 'Custom Settings';

      final item = DestinationItem<_TestDestination>(
        tag: tag,
        iconData: customIcon,
        caption: customCaption,
        viewBuilder: () => const SizedBox.shrink(),
      );

      expect(item.tag, equals(tag));
      expect(item.iconData, equals(customIcon));
      expect(item.caption, equals(customCaption));
    });

    test('invokes viewBuilder callback properly', () {
      const expectedKey = Key('rendered_view');
      final item = DestinationItem<_TestDestination>(
        tag: _TestDestination.home,
        viewBuilder: () => const SizedBox(
          key: expectedKey,
        ),
      );

      final widget = item.viewBuilder();

      expect(widget, isA<SizedBox>());
      expect((widget as SizedBox).key, equals(expectedKey));
    });
  });
}
