// packages/caption_switch/test/src/caption_switch_test.dart

import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

Switch _switchOf(WidgetTester tester) =>
    tester.widget<Switch>(find.byType(Switch));

void main() {
  group('CaptionSwitch', () {
    group('default constructor', () {
      testWidgets('renders caption, subtitle and current value', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: const Text('Caption'),
              subtitle: const Text('Subtitle'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.text('Caption'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.byType(SwitchListTile), findsOneWidget);
        expect(_switchOf(tester).value, isTrue);
      });

      testWidgets('renders without a subtitle', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: const Text('Caption'),
              value: false,
              onChanged: (_) {},
            ),
          ),
        );

        final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
        expect(tile.subtitle, isNull);
        expect(_switchOf(tester).value, isFalse);
      });

      testWidgets('accepts arbitrary caption widgets', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: const Icon(Icons.wifi),
              value: false,
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.byIcon(Icons.wifi), findsOneWidget);
      });

      testWidgets('forwards the new state to onChanged on tap', (tester) async {
        final received = <bool>[];

        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: const Text('Caption'),
              value: false,
              onChanged: received.add,
            ),
          ),
        );

        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        expect(received, [true]);
      });

      testWidgets('forwards false when toggled off', (tester) async {
        final received = <bool>[];

        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: const Text('Caption'),
              value: true,
              onChanged: received.add,
            ),
          ),
        );

        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        expect(received, [false]);
      });

      testWidgets('null onChanged disables the switch', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch(
              caption: Text('Caption ${DateTime.now().year}'),
              value: false,
              onChanged: null,
            ),
          ),
        );

        expect(_switchOf(tester).onChanged, isNull);

        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        expect(_switchOf(tester).value, isFalse);
      });
    });

    group('.text', () {
      const captionStyle = TextStyle(fontSize: 21, fontWeight: FontWeight.w700);
      const subtitleStyle = TextStyle(
        fontSize: 11,
        fontStyle: FontStyle.italic,
      );

      testWidgets('builds Text widgets from strings and applies styles', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch.text(
              caption: 'Caption',
              subtitle: 'Subtitle',
              textStyle: captionStyle,
              subtitleStyle: subtitleStyle,
              value: true,
              onChanged: (_) {},
            ),
          ),
        );

        final caption = tester.widget<Text>(find.text('Caption'));
        final subtitle = tester.widget<Text>(find.text('Subtitle'));

        expect(caption.style, captionStyle);
        expect(subtitle.style, subtitleStyle);
        expect(_switchOf(tester).value, isTrue);
      });

      testWidgets('leaves styles null when none are given', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch.text(
              caption: 'Caption',
              subtitle: 'Subtitle',
              value: false,
              onChanged: (_) {},
            ),
          ),
        );

        expect(tester.widget<Text>(find.text('Caption')).style, isNull);
        expect(tester.widget<Text>(find.text('Subtitle')).style, isNull);
      });

      testWidgets('omits the subtitle when null', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch.text(
              caption: 'Caption',
              value: false,
              onChanged: (_) {},
            ),
          ),
        );

        final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
        expect(tile.subtitle, isNull);
        expect(find.text('Caption'), findsOneWidget);
      });

      testWidgets('forwards the new state to onChanged on tap', (tester) async {
        final received = <bool>[];

        await tester.pumpWidget(
          _host(
            CaptionSwitch.text(
              caption: 'Caption',
              value: false,
              onChanged: received.add,
            ),
          ),
        );

        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        expect(received, [true]);
      });

      testWidgets('null onChanged disables the switch', (tester) async {
        await tester.pumpWidget(
          _host(
            CaptionSwitch.text(
              caption: 'Caption',
              value: true,
              onChanged: null,
            ),
          ),
        );

        expect(_switchOf(tester).onChanged, isNull);
      });
    });
  });
}
