// packages/theme_manager/lib/src/widgets/root/material_root.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/cubit.dart' show MaterialThemeCubit, MaterialThemeState;

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
// NOTE: If a context is needed anywhere one is NOT available
/*
   final BuildContext? ctx = globalNavigatorKey.currentContext;

Theme.of(ctx);              // ✅
MediaQuery.sizeOf(ctx);     // ✅  → WindowSizeClass.of(ctx) works too
Navigator.of(ctx);          // ✅
ScaffoldMessenger.of(ctx);  // ✅  MaterialApp inserts it above the Navigator
Localizations.of(...);      // ✅
Directionality.of(ctx);     // ✅

*/

class MaterialRoot extends StatelessWidget {
  const MaterialRoot(this.homeWidget, {this.showDebugBanner = true, super.key});

  final Widget homeWidget;
  final bool showDebugBanner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialThemeCubit, MaterialThemeState>(
      builder: (context, themeMode) {
        return MaterialApp(
          //Allows a 'global-ish' BuildContext (see NOTE)
          navigatorKey: globalNavigatorKey,
          themeAnimationDuration: kThemeAnimationDuration,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          theme: themeMode.light,
          darkTheme: themeMode.dark,
          themeMode: themeMode.mode,
          home: homeWidget,
          debugShowCheckedModeBanner: showDebugBanner,
        );
      },
    );
  }
}
