import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedOverlayCubit, AnimatedOverlay;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialThemeState;

class MaterialWidget extends StatelessWidget {
  const MaterialWidget(this.homeWidget, {super.key});
  final Widget homeWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialThemeCubit, MaterialThemeState>(
      builder: (context, themeMode) {
        return MaterialApp(
          theme: themeMode.light,
          darkTheme: themeMode.dark,
          themeMode: themeMode.mode,
          home: homeWidget,
          debugShowCheckedModeBanner: true,
          builder: (context, child) {
            context.read<AnimatedOverlayCubit>().showOverlay(
              CircularProgressIndicator(),
            );
            Future<void>.delayed(Duration(seconds: 3), () {
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
