// infinite_scroll_picking_settings/test/src/settings/settings_scope_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';

/// Captures the result of calling a `SettingsScope` accessor from a real
/// `BuildContext` so the test can assert on it.
class _Probe extends StatelessWidget {
  const _Probe({required this.onBuild});

  final void Function(BuildContext context) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return const SizedBox.shrink();
  }
}

void main() {
  group('SettingsScope', () {
    const seed = PickerVisualSettings(startingIndex: 1);

    testWidgets('of() returns the enclosing holder without subscribing',
        (tester) async {
      final holder = SettingsHolder(seed);
      late SettingsHolder captured;

      await tester.pumpWidget(
        SettingsScope(
          holder: holder,
          child: _Probe(
            onBuild: (context) => captured = SettingsScope.of(context),
          ),
        ),
      );

      expect(captured, same(holder));
    });

    testWidgets('of() does NOT rebuild dependents when the holder updates',
        (tester) async {
      final holder = SettingsHolder(seed);
      var builds = 0;

      await tester.pumpWidget(
        SettingsScope(
          holder: holder,
          child: _Probe(
            onBuild: (context) {
              SettingsScope.of(context);
              builds++;
            },
          ),
        ),
      );
      expect(builds, 1);

      holder.update(const PickerVisualSettings(startingIndex: 9));
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets('of() throws FlutterError when no SettingsScope is found',
        (tester) async {
      late Object? caught;

      await tester.pumpWidget(
        _Probe(
          onBuild: (context) {
            try {
              SettingsScope.of(context);
            } catch (e) {
              caught = e;
            }
          },
        ),
      );

      expect(caught, isA<FlutterError>());
      expect(
        (caught! as FlutterError).message,
        contains('SettingsScope.of() called with a context'),
      );
    });

    testWidgets(
      'watch() returns the current settings and subscribes to rebuilds',
      (tester) async {
        final holder = SettingsHolder(seed);
        final captured = <PickerVisualSettings>[];

        await tester.pumpWidget(
          SettingsScope(
            holder: holder,
            child: _Probe(
              onBuild: (context) =>
                  captured.add(SettingsScope.watch(context)),
            ),
          ),
        );
        expect(captured, [seed]);

        const next = PickerVisualSettings(startingIndex: 9);
        holder.update(next);
        await tester.pump();

        expect(captured, [seed, next]);
      },
    );

    testWidgets('watch() throws FlutterError when no SettingsScope is found',
        (tester) async {
      late Object? caught;

      await tester.pumpWidget(
        _Probe(
          onBuild: (context) {
            try {
              SettingsScope.watch(context);
            } catch (e) {
              caught = e;
            }
          },
        ),
      );

      expect(caught, isA<FlutterError>());
      expect(
        (caught! as FlutterError).message,
        contains('SettingsScope.watch() called with a context'),
      );
    });
  });
}
