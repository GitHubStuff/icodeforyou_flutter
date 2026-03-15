// test/src/_settings_content_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:settings_widget/src/_app_settings_entry.dart';
import 'package:settings_widget/src/_settings_content.dart';
import 'package:settings_widget/src/_settings_dismiss_button.dart';

class _StubEntry extends AppSettingsEntry {
  const _StubEntry({required this.label});
  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) => Text(label);
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('SettingsContent', () {
    testWidgets('renders title widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('My Title'),
            entries: const [_StubEntry(label: 'A')],
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders all entries', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('T'),
            entries: const [
              _StubEntry(label: 'Alpha'),
              _StubEntry(label: 'Beta'),
              _StubEntry(label: 'Gamma'),
            ],
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('renders dismiss button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('T'),
            entries: const [_StubEntry(label: 'A')],
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(SettingsDismissButton), findsOneWidget);
    });

    testWidgets('fires onDismiss via dismiss button', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('T'),
            entries: const [_StubEntry(label: 'A')],
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('inserts gaps between multiple entries', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('T'),
            entries: const [
              _StubEntry(label: 'A'),
              _StubEntry(label: 'B'),
              _StubEntry(label: 'C'),
            ],
            onDismiss: () {},
          ),
        ),
      );

      // 3 entries → 2 gaps between them
      expect(find.byType(Gap), findsWidgets);
    });

    testWidgets('no gap for single entry', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('T'),
            entries: const [_StubEntry(label: 'Only')],
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Only'), findsOneWidget);
    });

    testWidgets('applies bold 24pt style to title via DefaultTextStyle',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsContent(
            title: const Text('Styled'),
            entries: const [_StubEntry(label: 'A')],
            onDismiss: () {},
          ),
        ),
      );

      final defaults = tester
          .widgetList<DefaultTextStyle>(find.byType(DefaultTextStyle))
          .toList();

      final merged = defaults.firstWhere(
        (d) => d.style.fontSize == 24,
        orElse: () => throw TestFailure('No 24pt DefaultTextStyle found'),
      );

      expect(merged.style.fontWeight, FontWeight.bold);
    });
  });
}
