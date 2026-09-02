// packages/infinite_scroll_picking_settings/test/src/settings/settings_scope_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_holder.dart'
    show SettingsHolder;
import 'package:infinite_scroll_picking_settings/src/settings/settings_scope.dart'
    show SettingsScope;

void main() {
  group('SettingsScope', () {
    testWidgets('of returns the holder without subscribing',
        (tester) async {
      final holder = SettingsHolder(const PickerVisualSettings());
      addTearDown(holder.dispose);
      late SettingsHolder resolved;
      var builds = 0;

      await tester.pumpWidget(
        SettingsScope(
          holder: holder,
          child: Builder(
            builder: (context) {
              builds++;
              resolved = SettingsScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, same(holder));

      holder.update(const PickerVisualSettings(startingIndex: 1));
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets('watch returns the value and rebuilds on holder updates',
        (tester) async {
      final holder = SettingsHolder(const PickerVisualSettings());
      addTearDown(holder.dispose);

      await tester.pumpWidget(
        SettingsScope(
          holder: holder,
          child: Builder(
            builder: (context) {
              final settings = SettingsScope.watch(context);
              return Text(
                'index:${settings.startingIndex}',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );

      expect(find.text('index:0'), findsOneWidget);

      holder.update(const PickerVisualSettings(startingIndex: 5));
      await tester.pump();

      expect(find.text('index:5'), findsOneWidget);
    });

    testWidgets('of throws FlutterError without an enclosing scope',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(
        () => SettingsScope.of(captured),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('watch throws FlutterError without an enclosing scope',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(
        () => SettingsScope.watch(captured),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
