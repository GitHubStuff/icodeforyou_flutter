// test/src/_theme_radio_row_test.dart

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';
import 'package:theme_selection_widget/src/_theme_radio_row.dart';

void main() {
  const option = ThemeOption(
    mode: ThemeMode.dark,
    icon: Icons.dark_mode,
    label: 'Dark',
  );

  Widget _buildSubject({
    required bool selected,
    required ValueChanged<ThemeMode> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ThemeRadioRow(
          option: option,
          selected: selected,
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('ThemeRadioRow', () {
    testWidgets('renders icon, label, and radio', (tester) async {
      await tester.pumpWidget(
        _buildSubject(selected: false, onChanged: (_) {}),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.byType(Radio<ThemeMode>), findsOneWidget);
    });

    testWidgets('RadioGroup groupValue is set when selected is true',
        (tester) async {
      await tester.pumpWidget(
        _buildSubject(selected: true, onChanged: (_) {}),
      );

      final group = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(group.groupValue, ThemeMode.dark);
    });

    testWidgets('RadioGroup groupValue is null when selected is false',
        (tester) async {
      await tester.pumpWidget(
        _buildSubject(selected: false, onChanged: (_) {}),
      );

      final group = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(group.groupValue, isNull);
    });

    testWidgets('onChanged called when InkWell tapped', (tester) async {
      ThemeMode? received;
      await tester.pumpWidget(
        _buildSubject(
          selected: false,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(received, ThemeMode.dark);
    });

    testWidgets('onChanged called when Radio tapped', (tester) async {
      ThemeMode? received;
      await tester.pumpWidget(
        _buildSubject(
          selected: false,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.byType(Radio<ThemeMode>));
      expect(received, ThemeMode.dark);
    });
  });
}
