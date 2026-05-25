// test/src/_theme_selection_body_text_style_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/theme_option.dart';
import '../../lib/src/theme_selection_body.dart';

const _options = <ThemeOption>[
  ThemeOption(
    mode: ThemeMode.system,
    icon: Icons.brightness_auto,
    label: 'System',
  ),
  ThemeOption(mode: ThemeMode.dark, icon: Icons.dark_mode, label: 'Dark'),
  ThemeOption(mode: ThemeMode.light, icon: Icons.light_mode, label: 'Light'),
];

Widget _build({ThemeData? theme}) => MaterialApp(
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
  final paragraph = tester.renderObject<RenderParagraph>(
    find.text(text).first,
  );
  return paragraph.text.style?.fontSize ??
      paragraph.textSize.height;
}

void main() {
  group('ThemeSelectionBody — title text style', () {
    testWidgets('title renders without error', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('title fontSize is larger than label fontSize', (tester) async {
      await tester.pumpWidget(_build());
      await tester.pump();
      final titleSize = _renderedFontSize(tester, 'Theme');
      final labelSize = _renderedFontSize(tester, 'Dark');
      expect(titleSize, greaterThan(labelSize));
    });

    testWidgets('title rendered fontSize is 22.0 (M3 titleLarge)',
        (tester) async {
      await tester.pumpWidget(_build());
      await tester.pump();
      final titleSize = _renderedFontSize(tester, 'Theme');
      expect(titleSize, 22.0);
    });

    testWidgets('label rendered fontSize is 14.0 (M3 bodyMedium)',
        (tester) async {
      await tester.pumpWidget(_build());
      await tester.pump();
      final labelSize = _renderedFontSize(tester, 'Dark');
      expect(labelSize, 14.0);
    });
  });
}
