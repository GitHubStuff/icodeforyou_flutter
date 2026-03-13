// test/src/_theme_selection_body_test.dart

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';
import 'package:theme_selection_widget/src/_theme_radio_row.dart';
import 'package:theme_selection_widget/src/_theme_selection_body.dart';

void main() {
  final options = [
    const ThemeOption(
      mode: ThemeMode.system,
      icon: Icons.brightness_auto,
      label: 'System',
    ),
    const ThemeOption(
      mode: ThemeMode.dark,
      icon: Icons.dark_mode,
      label: 'Dark',
    ),
    const ThemeOption(
      mode: ThemeMode.light,
      icon: Icons.light_mode,
      label: 'Light',
    ),
  ];

  Widget _buildSubject({
    required ThemeMode current,
    required ValueChanged<ThemeMode> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ThemeSelectionBody(
          title: 'Theme',
          options: options,
          current: current,
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('ThemeSelectionBody', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('renders a ThemeRadioRow for each option', (tester) async {
      await tester.pumpWidget(
        _buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      expect(find.byType(ThemeRadioRow), findsNWidgets(options.length));
    });

    testWidgets('only the current mode row is selected', (tester) async {
      await tester.pumpWidget(
        _buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      final rows = tester.widgetList<ThemeRadioRow>(
        find.byType(ThemeRadioRow),
      ).toList();

      expect(rows[0].selected, isFalse);
      expect(rows[1].selected, isTrue);
      expect(rows[2].selected, isFalse);
    });

    testWidgets('onChanged fires with correct mode when row tapped',
        (tester) async {
      ThemeMode? received;
      await tester.pumpWidget(
        _buildSubject(
          current: ThemeMode.dark,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.text('Light'));
      expect(received, ThemeMode.light);
    });

    testWidgets('renders bordered container', (tester) async {
      await tester.pumpWidget(
        _buildSubject(current: ThemeMode.system, onChanged: (_) {}),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });
}
