// packages/theme_framework/test/src/default_material_app_router_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/theme_framework.dart'
    show DefaultMaterialAppRouter, ThemeCubit, ThemeStorageAbstract;

/// A lightweight fake to satisfy the [ThemeCubit] dependency.
class _FakeThemeStorage implements ThemeStorageAbstract {
  ThemeMode? storedMode;

  @override
  Future<ThemeMode?> read() async => storedMode;

  @override
  Future<void> write(ThemeMode mode) async {
    storedMode = mode;
  }
}

/// A minimal router delegate to satisfy [RouterConfig].
class _DummyRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Dummy Route'));

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

void main() {
  group('DefaultMaterialAppRouter', () {
    late _FakeThemeStorage storage;
    late ThemeCubit cubit;
    late RouterConfig<Object> routerConfig;

    setUp(() {
      storage = _FakeThemeStorage();
      cubit = ThemeCubit(storage);

      // FIX: RouterConfig requires either both a parser AND a provider, or neither.
      // For this test, a delegate alone is sufficient.
      routerConfig = RouterConfig<Object>(
        routerDelegate: _DummyRouterDelegate(),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('applies fallback themes when explicit themes are omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        DefaultMaterialAppRouter(
          themeCubit: cubit,
          routerConfig: routerConfig,
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify the app defaults to false for the debug banner
      expect(materialApp.debugShowCheckedModeBanner, isFalse);

      // Verify fallback light theme
      expect(materialApp.theme?.brightness, Brightness.light);

      // Verify fallback dark theme (with black scaffold background)
      expect(materialApp.darkTheme?.brightness, Brightness.dark);
      expect(materialApp.darkTheme?.scaffoldBackgroundColor, Colors.black);

      // Verify high contrast themes fall back to null (which delegates to standard themes)
      expect(materialApp.highContrastTheme, isNull);
      expect(materialApp.highContrastDarkTheme, isNull);
    });

    testWidgets('applies explicit themes when provided', (tester) async {
      final customTheme = ThemeData(primaryColor: Colors.red);
      final customDarkTheme = ThemeData(primaryColor: Colors.blue);
      final customHighContrastTheme = ThemeData(primaryColor: Colors.green);
      final customHighContrastDarkTheme = ThemeData(
        primaryColor: Colors.yellow,
      );

      await tester.pumpWidget(
        DefaultMaterialAppRouter(
          themeCubit: cubit,
          routerConfig: routerConfig,
          theme: customTheme,
          darkTheme: customDarkTheme,
          highContrastTheme: customHighContrastTheme,
          highContrastDarkTheme: customHighContrastDarkTheme,
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.theme, customTheme);
      expect(materialApp.darkTheme, customDarkTheme);
      expect(materialApp.highContrastTheme, customHighContrastTheme);
      expect(materialApp.highContrastDarkTheme, customHighContrastDarkTheme);
    });

    testWidgets('rebuilds MaterialApp when ThemeCubit state changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        DefaultMaterialAppRouter(
          themeCubit: cubit,
          routerConfig: routerConfig,
        ),
      );

      // Verify initial theme mode (ThemeCubit starts at ThemeMode.dark for the splash screen)
      var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      // Act: Change the theme mode
      cubit.setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();

      // Verify the BlocBuilder triggered a rebuild with the new mode
      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);

      // Act: Change to system mode
      cubit.setThemeMode(ThemeMode.system);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);
    });
  });
}
