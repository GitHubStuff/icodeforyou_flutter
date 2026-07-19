// test/src/settings_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/settings_widget.dart';
import 'package:settings_widget/src/settings_layout.dart';
import 'package:settings_widget/src/settings_sheet.dart';

class _StubEntry extends AppSettingsEntry {
  const _StubEntry({required this.label});
  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) => Text(label);
}

class _Host extends StatelessWidget {
  const _Host({
    required this.direction,
    this.breakpoint = 600,
    this.edgeGap = 16,
    this.title,
  });

  final SettingsDirection direction;
  final double breakpoint;
  final double edgeGap;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => SettingsWidget.show(
        context,
        entries: const [_StubEntry(label: 'Entry')],
        direction: direction,
        breakpoint: breakpoint,
        edgeGap: edgeGap,
        title: title ??
            const Text(
              'Settings...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
      ),
      child: const Text('Open'),
    );
  }
}

Widget _wrap({
  SettingsDirection direction = SettingsDirection.bottom,
  double breakpoint = 600,
  double edgeGap = 16,
  Widget? title,
}) =>
    MaterialApp(
      home: Scaffold(
        body: _Host(
          direction: direction,
          breakpoint: breakpoint,
          edgeGap: edgeGap,
          title: title,
        ),
      ),
    );

void main() {
  group('SettingsWidget.show', () {
    testWidgets('opens dialog on tap', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsLayout), findsOneWidget);
      expect(find.byType(SettingsSheet), findsOneWidget);
    });

    testWidgets('dismisses on close tap', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsNothing);
    });

    testWidgets('renders entries', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Entry'), findsOneWidget);
    });

    testWidgets('renders default title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Settings...'), findsOneWidget);
    });

    testWidgets('renders custom title', (tester) async {
      await tester.pumpWidget(
        _wrap(title: const Text('My Prefs')),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('My Prefs'), findsOneWidget);
    });

    testWidgets('is not barrier dismissible', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the barrier area
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsOneWidget);
    });

    group('directions', () {
      for (final direction in SettingsDirection.values) {
        testWidgets('opens with direction $direction', (tester) async {
          await tester.pumpWidget(_wrap(direction: direction));
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          final layout = tester.widget<SettingsLayout>(
            find.byType(SettingsLayout),
          );
          expect(layout.direction, direction);
        });
      }
    });

    testWidgets('passes edgeGap to SettingsLayout', (tester) async {
      await tester.pumpWidget(_wrap(edgeGap: 32));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final layout = tester.widget<SettingsLayout>(
        find.byType(SettingsLayout),
      );
      expect(layout.edgeGap, 32);
    });

    testWidgets('passes breakpoint to SettingsSheet', (tester) async {
      await tester.pumpWidget(_wrap(breakpoint: 800));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final sheet = tester.widget<SettingsSheet>(find.byType(SettingsSheet));
      expect(sheet.breakpoint, 800);
    });
  });
}
