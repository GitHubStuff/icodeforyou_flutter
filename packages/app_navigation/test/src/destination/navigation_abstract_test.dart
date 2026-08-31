// packages/app_navigation/test/src/destination/navigation_abstract_test.dart
import 'package:app_navigation/src/destination/navigation_abstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _TestNavigableDestination implements NavigableDestinationAbstract {
  home(
    caption: 'Home Caption',
    iconData: Icons.home,
    viewBuilder: _buildHomeView,
  ),
  settings(
    caption: 'Settings Caption',
    iconData: Icons.settings,
    viewBuilder: _buildSettingsView,
  );

  const _TestNavigableDestination({
    required this.caption,
    required this.iconData,
    required this.viewBuilder,
  });

  @override
  final String caption;

  @override
  final IconData iconData;

  @override
  final Widget Function() viewBuilder;

  static Widget _buildHomeView() => const Text('Home View');
  static Widget _buildSettingsView() => const Text('Settings View');
}

void main() {
  group('NavigableDestinationAbstract', () {
    test('implements Enum correctly', () {
      const destination = _TestNavigableDestination.home;

      expect(destination, isA<Enum>());
      expect(destination.name, equals('home'));
      expect(destination.index, equals(0));
    });

    test('exposes correct iconData', () {
      const home = _TestNavigableDestination.home;
      const settings = _TestNavigableDestination.settings;

      expect(home.iconData, equals(Icons.home));
      expect(settings.iconData, equals(Icons.settings));
    });

    test('exposes correct caption', () {
      const home = _TestNavigableDestination.home;
      const settings = _TestNavigableDestination.settings;

      expect(home.caption, equals('Home Caption'));
      expect(settings.caption, equals('Settings Caption'));
    });

    test('exposes and invokes viewBuilder callback', () {
      const home = _TestNavigableDestination.home;
      const settings = _TestNavigableDestination.settings;

      final homeWidget = home.viewBuilder();
      final settingsWidget = settings.viewBuilder();

      expect(homeWidget, isA<Text>());
      expect((homeWidget as Text).data, equals('Home View'));

      expect(settingsWidget, isA<Text>());
      expect((settingsWidget as Text).data, equals('Settings View'));
    });
  });
}
