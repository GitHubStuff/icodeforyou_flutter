// theme_widget/test/src/theme_selection_body_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_widget/src/theme_option.dart';
import 'package:theme_widget/src/theme_radio_row.dart';
import 'package:theme_widget/src/theme_selection_body.dart';

void main() {
  const options = <ThemeOption>[
    ThemeOption(
      mode: ThemeMode.system,
      icon: Icons.brightness_auto,
      label: 'System',
    ),
    ThemeOption(
      mode: ThemeMode.dark,
      icon: Icons.dark_mode,
      label: 'Dark',
    ),
    ThemeOption(
      mode: ThemeMode.light,
      icon: Icons.light_mode,
      label: 'Light',
    ),
  ];

  Widget buildSubject({
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
        buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('renders a ThemeRadioRow for each option', (tester) async {
      await tester.pumpWidget(
        buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      expect(find.byType(ThemeRadioRow), findsNWidgets(options.length));
    });

    testWidgets('RadioGroup groupValue matches current mode', (tester) async {
      await tester.pumpWidget(
        buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      final group = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(group.groupValue, ThemeMode.dark);
    });

    testWidgets('RadioGroup groupValue updates when current mode changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(current: ThemeMode.system, onChanged: (_) {}),
      );

      var group = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(group.groupValue, ThemeMode.system);

      await tester.pumpWidget(
        buildSubject(current: ThemeMode.light, onChanged: (_) {}),
      );

      group = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(group.groupValue, ThemeMode.light);
    });

    testWidgets('onChanged fires with correct mode when row is tapped', (
      tester,
    ) async {
      ThemeMode? received;

      await tester.pumpWidget(
        buildSubject(
          current: ThemeMode.dark,
          onChanged: (mode) => received = mode,
        ),
      );

      await tester.tap(find.text('Light'));
      await tester.pump();

      expect(received, ThemeMode.light);
    });

    testWidgets('each row exposes its own option mode via its Radio', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(current: ThemeMode.dark, onChanged: (_) {}),
      );

      final radios = tester
          .widgetList<Radio<ThemeMode>>(find.byType(Radio<ThemeMode>))
          .toList();

      expect(radios.map((r) => r.value), [
        ThemeMode.system,
        ThemeMode.dark,
        ThemeMode.light,
      ]);
    });
  });
}
