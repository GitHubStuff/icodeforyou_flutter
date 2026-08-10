// packages/settings_widget/test/src/app_settings_entry_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/app_settings_entry.dart';

class _ConcreteEntry extends AppSettingsEntry {
  const _ConcreteEntry({super.key});

  @override
  Widget build(BuildContext context) => const Text('Entry');
}

void main() {
  group('AppSettingsEntry', () {
    testWidgets('concrete subclass constructs and renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _ConcreteEntry())),
      );

      expect(find.text('Entry'), findsOneWidget);
    });
  });
}
