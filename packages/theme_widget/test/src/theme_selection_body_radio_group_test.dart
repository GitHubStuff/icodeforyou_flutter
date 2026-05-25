// theme_widget/test/src/theme_selection_body_radio_group_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_widget/src/theme_option.dart';
import 'package:theme_widget/src/theme_selection_body.dart';

void main() {
  group('ThemeSelectionBody — RadioGroup.onChanged', () {
    testWidgets(
      'tapping a Radio<ThemeMode> inside the group fires onChanged '
      'with the tapped mode',
      (tester) async {
        ThemeMode? captured;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeSelectionBody(
                title: 'Theme',
                current: ThemeMode.dark,
                options: const [
                  ThemeOption(
                    mode: ThemeMode.light,
                    icon: Icons.light_mode,
                    label: 'Light',
                  ),
                  ThemeOption(
                    mode: ThemeMode.dark,
                    icon: Icons.dark_mode,
                    label: 'Dark',
                  ),
                  ThemeOption(
                    mode: ThemeMode.system,
                    icon: Icons.brightness_auto,
                    label: 'System',
                  ),
                ],
                onChanged: (mode) => captured = mode,
              ),
            ),
          ),
        );

        // Find the Radio<ThemeMode> whose value is ThemeMode.light and tap
        // it directly. Tapping the underlying Radio (not the row's tap
        // surface) routes the change through RadioGroup<ThemeMode>.onChanged,
        // exercising the group's callback.
        final lightRadio = find.byWidgetPredicate(
          (widget) =>
              widget is Radio<ThemeMode> && widget.value == ThemeMode.light,
        );
        expect(lightRadio, findsOneWidget);

        await tester.tap(lightRadio);
        await tester.pumpAndSettle();

        expect(captured, ThemeMode.light);
      },
    );
  });
}
