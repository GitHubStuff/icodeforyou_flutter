// theme_manager/test/src/theme_service/material_widget_coverage_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/theme_manager.dart'
    show MaterialTheme, MaterialThemeCubit, MaterialWidget, ThemePersistenceAbstract;

/// In-memory persistence double. The cubit only writes on a mode change, which
/// these tests never trigger, so both members are inert.
class _FakeThemePersistence extends ThemePersistenceAbstract {
  @override
  ThemeMode load() => ThemeMode.dark;

  @override
  void save(ThemeMode mode) {}
}

void main() {
  group('MaterialWidget', () {
    testWidgets('builds a MaterialApp from the cubit state with homeWidget as '
        'its home', (tester) async {
      const home = SizedBox(key: Key('home'));

      await tester.pumpWidget(
        BlocProvider<MaterialThemeCubit>(
          create: (_) => MaterialThemeCubit(
            theme: MaterialTheme(),
            themeModeStorage: _FakeThemePersistence(),
          ),
          child: const MaterialWidget(home),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.home, same(home));
      expect(app.themeMode, ThemeMode.dark);
      expect(app.theme, isNotNull);
      expect(app.darkTheme, isNotNull);
      expect(find.byKey(const Key('home')), findsOneWidget);
    });

    test('constructor stores homeWidget when built in a non-const context', () {
      // A non-const argument forces a runtime (non-canonicalized)
      // invocation of the const constructor, so the field-assigning
      // constructor body actually executes — and we assert its contract.
      final home = Container();
      final widget = MaterialWidget(home);

      expect(widget.homeWidget, same(home));
    });
  });
}
