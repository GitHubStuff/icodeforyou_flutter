// test/src/_theme_radio_row_text_style_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';
import 'package:theme_selection_widget/src/_theme_radio_row.dart';
import 'package:theme_selection_widget/src/_theme_selection_body.dart';

const _option = ThemeOption(
  mode: ThemeMode.dark,
  icon: Icons.dark_mode,
  label: 'Dark',
);

const _options = <ThemeOption>[
  ThemeOption(
    mode: ThemeMode.system,
    icon: Icons.brightness_auto,
    label: 'System',
  ),
  ThemeOption(mode: ThemeMode.dark, icon: Icons.dark_mode, label: 'Dark'),
  ThemeOption(mode: ThemeMode.light, icon: Icons.light_mode, label: 'Light'),
];

Widget _buildRow({ThemeData? theme}) => MaterialApp(
  theme: theme ?? ThemeData.light(useMaterial3: true),
  home: Scaffold(
    body: ThemeRadioRow(option: _option, selected: false, onChanged: (_) {}),
  ),
);

Widget _buildBody({ThemeData? theme}) => MaterialApp(
  theme: theme ?? ThemeData.light(useMaterial3: true),
  home: Scaffold(
    body: ThemeSelectionBody(
      title: 'Theme',
      options: _options,
      current: ThemeMode.system,
      onChanged: (_) {},
    ),
  ),
);

double _renderedFontSize(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text).first);
  return paragraph.text.style?.fontSize ?? paragraph.textSize.height;
}

void main() {
  group('ThemeRadioRow — label text style', () {
    testWidgets('label renders without error', (tester) async {
      await tester.pumpWidget(_buildRow());
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('label fontSize is smaller than title fontSize', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBody());
      await tester.pump();
      final titleSize = _renderedFontSize(tester, 'Theme');
      final labelSize = _renderedFontSize(tester, 'Dark');
      expect(labelSize, lessThan(titleSize));
    });

    testWidgets('title and label have different rendered font sizes', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBody());
      await tester.pump();
      final titleSize = _renderedFontSize(tester, 'Theme');
      final labelSize = _renderedFontSize(tester, 'Dark');
      expect(titleSize, isNot(equals(labelSize)));
    });

    testWidgets('label rendered fontSize is 14.0 (M3 bodyMedium)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBody());
      await tester.pump();
      final labelSize = _renderedFontSize(tester, 'Dark');
      expect(labelSize, 14.0);
    });

    testWidgets('title rendered fontSize is 22.0 (M3 titleLarge)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBody());
      await tester.pump();
      final titleSize = _renderedFontSize(tester, 'Theme');
      expect(titleSize, 22.0);
    });
  });
}
