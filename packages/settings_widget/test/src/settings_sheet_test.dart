// test/src/_settings_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/_app_settings_entry.dart';
import 'package:settings_widget/src/_settings_sheet.dart';

class _StubEntry extends AppSettingsEntry {
  const _StubEntry({required this.label});
  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) => Text(label);
}

Widget _wrap(double screenWidth, double breakpoint) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(screenWidth, 800)),
        child: Scaffold(
          body: SettingsSheet(
            title: const Text('Title'),
            entries: const [_StubEntry(label: 'Entry')],
            onDismiss: () {},
            breakpoint: breakpoint,
          ),
        ),
      ),
    );

void main() {
  group('SettingsSheet', () {
    testWidgets('uses phone layout when width is below breakpoint',
        (tester) async {
      await tester.pumpWidget(_wrap(400, 600));

      // Phone layout wraps in SafeArea
      expect(find.byType(SafeArea), findsOneWidget);
      // Tablet padding should not be present
      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .where(
            (p) =>
                p.padding ==
                const EdgeInsets.only(
                  left: 48,
                  right: 48,
                  top: 48,
                  bottom: 96,
                ),
          )
          .toList();
      expect(paddings, isEmpty);
    });

    testWidgets('uses tablet layout when width meets breakpoint',
        (tester) async {
      await tester.pumpWidget(_wrap(800, 600));

      // Tablet layout applies specific padding
      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .where(
            (p) =>
                p.padding ==
                const EdgeInsets.only(
                  left: 48,
                  right: 48,
                  top: 48,
                  bottom: 96,
                ),
          )
          .toList();
      expect(paddings, isNotEmpty);
    });

    testWidgets('renders entry content', (tester) async {
      await tester.pumpWidget(_wrap(400, 600));
      expect(find.text('Entry'), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(400, 600));
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('fires onDismiss', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Scaffold(
              body: SettingsSheet(
                title: const Text('T'),
                entries: const [_StubEntry(label: 'E')],
                onDismiss: () => dismissed = true,
                breakpoint: 600,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
