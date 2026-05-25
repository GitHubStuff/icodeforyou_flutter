// packages/theme_manager/lib/src/theme_service/material_widget.dart
// ignore_for_file: public_member_api_docs
import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedOverlay, AnimatedOverlayCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialThemeState;
import 'package:widget_themes/widget_themes.dart' show CrossFadeTheme;

class MaterialWidget extends StatelessWidget {
  const MaterialWidget(this.homeWidget, {super.key});

  final Widget homeWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialThemeCubit, MaterialThemeState>(
      builder: (context, themeMode) {
        return MaterialApp(
          theme: themeMode.light.copyWith(
            extensions: const [CrossFadeTheme()],
          ),
          darkTheme: themeMode.dark.copyWith(
            extensions: const [CrossFadeTheme()],
          ),
          themeMode: themeMode.mode,
          home: homeWidget,
          debugShowCheckedModeBanner: true,
          builder: (context, child) {
            context.read<AnimatedOverlayCubit>().showOverlay(
              const CircularProgressIndicator(),
            );
            Future<void>.delayed(const Duration(milliseconds: 950), () {
              if (context.mounted) {
                context.read<AnimatedOverlayCubit>().removeOverlay();
              }
            });
            return AnimatedOverlay(child: child);
          },
        );
      },
    );
  }
}
