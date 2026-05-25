// theme_manager/test/src/theme_service/material_widget_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/src/theme_mode/theme_persistence_abstract.dart'
    show ThemePersistenceAbstract;
import 'package:theme_manager/theme_manager.dart';

class _InMemoryThemePersistence implements ThemePersistenceAbstract {
  ThemeMode _stored = ThemeMode.system;

  @override
  ThemeMode load() => _stored;

  @override
  void save(ThemeMode mode) {
    _stored = mode;
  }
}

void main() {
  group('MaterialWidget', () {
    late MaterialTheme initialTheme;
    late MaterialThemeCubit themeCubit;
    late AnimatedOverlayCubit overlayCubit;

    setUp(() {
      initialTheme = MaterialTheme(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        mode: ThemeMode.light,
      );
      themeCubit = MaterialThemeCubit(
        theme: initialTheme,
        themeModeStorage: _InMemoryThemePersistence(),
      );
      overlayCubit = AnimatedOverlayCubit();
    });

    tearDown(() async {
      await themeCubit.close();
      await overlayCubit.close();
    });

    Widget buildSubject(Widget home) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<MaterialThemeCubit>.value(value: themeCubit),
          BlocProvider<AnimatedOverlayCubit>.value(value: overlayCubit),
        ],
        child: MaterialWidget(home),
      );
    }

    testWidgets('renders the home widget inside MaterialApp', (tester) async {
      const homeKey = Key('home');

      await tester.pumpWidget(
        buildSubject(const SizedBox(key: homeKey)),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('applies theme state to MaterialApp', (tester) async {
      await tester.pumpWidget(buildSubject(const SizedBox()));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, themeCubit.state.light);
      expect(materialApp.darkTheme, themeCubit.state.dark);
      expect(materialApp.themeMode, themeCubit.state.mode);
    });

    testWidgets('shows overlay on build and removes it after the delay', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(const SizedBox()));

      expect(overlayCubit.state.child, isNotNull);
      expect(find.byType(AnimatedOverlay), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));

      expect(overlayCubit.state.child, isNull);
    });

    testWidgets('rebuilds when theme state changes', (tester) async {
      await tester.pumpWidget(buildSubject(const SizedBox()));

      themeCubit.toDark();
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}
