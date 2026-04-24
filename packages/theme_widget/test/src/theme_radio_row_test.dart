// theme_widget/test/src/theme_radio_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_widget/src/theme_option.dart';
import 'package:theme_widget/src/theme_radio_row.dart';

void main() {
  const option = ThemeOption(
    mode: ThemeMode.dark,
    icon: Icons.dark_mode,
    label: 'Dark',
  );

  Widget buildSubject({
    required ThemeMode? groupValue,
    required ValueChanged<ThemeMode> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RadioGroup<ThemeMode>(
          groupValue: groupValue,
          onChanged: (mode) {
            if (mode != null) onChanged(mode);
          },
          child: ThemeRadioRow(
            option: option,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('ThemeRadioRow', () {
    testWidgets('renders icon, label, and radio', (tester) async {
      await tester.pumpWidget(
        buildSubject(groupValue: null, onChanged: (_) {}),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.byType(Radio<ThemeMode>), findsOneWidget);
    });

    testWidgets('Radio value reflects the option mode', (tester) async {
      await tester.pumpWidget(
        buildSubject(groupValue: null, onChanged: (_) {}),
      );

      final radio = tester.widget<Radio<ThemeMode>>(
        find.byType(Radio<ThemeMode>),
      );
      expect(radio.value, ThemeMode.dark);
    });

    testWidgets('onChanged fires with option mode when label is tapped', (
      tester,
    ) async {
      ThemeMode? received;

      await tester.pumpWidget(
        buildSubject(
          groupValue: null,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.text('Dark'));
      await tester.pump();

      expect(received, ThemeMode.dark);
    });

    testWidgets('onChanged fires with option mode when icon is tapped', (
      tester,
    ) async {
      ThemeMode? received;

      await tester.pumpWidget(
        buildSubject(
          groupValue: null,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      expect(received, ThemeMode.dark);
    });
  });
}
