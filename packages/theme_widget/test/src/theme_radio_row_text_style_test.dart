// theme_widget/test/src/theme_radio_row_text_style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_widget/src/theme_option.dart';
import 'package:theme_widget/src/theme_selection_body.dart';

const options = <ThemeOption>[
  ThemeOption(
    mode: ThemeMode.system,
    icon: Icons.brightness_auto,
    label: 'System',
  ),
  ThemeOption(mode: ThemeMode.dark, icon: Icons.dark_mode, label: 'Dark'),
  ThemeOption(mode: ThemeMode.light, icon: Icons.light_mode, label: 'Light'),
];

Widget buildBody({ThemeData? theme}) => MaterialApp(
  theme: theme ?? ThemeData.light(useMaterial3: true),
  home: Scaffold(
    body: ThemeSelectionBody(
      title: 'Theme',
      options: options,
      current: ThemeMode.system,
      onChanged: (_) {},
    ),
  ),
);

double renderedFontSize(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  return paragraph.text.style!.fontSize!;
}

void main() {
  group('ThemeSelectionBody — text styles', () {
    testWidgets('title and all option labels render', (tester) async {
      await tester.pumpWidget(buildBody());

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('label fontSize is smaller than title fontSize', (
      tester,
    ) async {
      await tester.pumpWidget(buildBody());

      final titleSize = renderedFontSize(tester, 'Theme');
      final labelSize = renderedFontSize(tester, 'Dark');

      expect(labelSize, lessThan(titleSize));
    });

    testWidgets('label rendered fontSize is 14.0 (M3 bodyMedium)', (
      tester,
    ) async {
      await tester.pumpWidget(buildBody());

      expect(renderedFontSize(tester, 'Dark'), 14.0);
    });

    testWidgets('title rendered fontSize is 22.0 (M3 titleLarge)', (
      tester,
    ) async {
      await tester.pumpWidget(buildBody());

      expect(renderedFontSize(tester, 'Theme'), 22.0);
    });
  });
}
