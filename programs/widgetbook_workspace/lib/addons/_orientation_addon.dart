// lib/addons/_orientation_addon.dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// A [WidgetbookAddon] that overrides the [MediaQuery] orientation for every
/// use-case, allowing the reviewer to toggle between portrait and landscape
/// without changing the host device viewport.
class OrientationAddon extends WidgetbookAddon<Orientation> {
  OrientationAddon() : super(name: 'Orientation');

  static const _fieldName = 'orientation';

  @override
  List<Field> get fields => [
        ObjectDropdownField<Orientation>(
          name: _fieldName,
          values: const [Orientation.portrait, Orientation.landscape],
          initialValue: Orientation.portrait,
          labelBuilder: (orientation) => switch (orientation) {
            Orientation.portrait => 'Portrait',
            Orientation.landscape => 'Landscape',
          },
        ),
      ];

  @override
  Orientation valueFromQueryGroup(Map<String, String> group) {
    return valueOf<Orientation>(_fieldName, group) ?? Orientation.portrait;
  }

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    Orientation setting,
  ) {
    final mq = MediaQuery.of(context);

    final size = switch (setting) {
      Orientation.portrait => Size(
          mq.size.shortestSide,
          mq.size.longestSide,
        ),
      Orientation.landscape => Size(
          mq.size.longestSide,
          mq.size.shortestSide,
        ),
    };

    return MediaQuery(
      data: mq.copyWith(size: size),
      child: child,
    );
  }
}
