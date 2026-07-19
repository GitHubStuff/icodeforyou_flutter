// test/src/_app_settings_entry_test.dart

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/app_settings_entry.dart';

class _ConcreteEntry extends AppSettingsEntry {
  const _ConcreteEntry({super.key});

  @override
  Widget get title => const Text('Title');

  @override
  Widget build(BuildContext context) => const Text('Entry');
}

void main() {
  group('AppSettingsEntry', () {
    testWidgets('concrete subclass constructs and renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _ConcreteEntry(),
          ),
        ),
      );

      expect(find.text('Entry'), findsOneWidget);
    });

    testWidgets('title getter returns correct widget', (tester) async {
      const entry = _ConcreteEntry();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => entry.title,
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
    });
  });
}
