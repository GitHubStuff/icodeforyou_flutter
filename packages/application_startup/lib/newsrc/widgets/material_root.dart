// application_startup/lib/src/runner/_app_widget.dart

// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/widgets/splash_screen_configuration.dart'
    show SplashScreenConfiguration;
import 'package:application_startup/newsrc/startup_task/base_service_item.dart'
    show BaseServiceItem;
import 'package:application_startup/newsrc/widgets/startup_display_widget.dart'
    show StartupDisplayWidget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart';

class MaterialRoot extends StatefulWidget {
  const MaterialRoot({
    required BaseServiceItem<dynamic> themeTask,
    required BaseServiceItem<dynamic> spinnerTask,
    required SplashScreenConfiguration configuration,
    required ThemeData darkTheme,
    required ThemeData lightTheme,
    super.key,
  }) : _themeTask = themeTask,
       _spinnerTask = spinnerTask,
       _configuration = configuration,
       _darkTheme = darkTheme,
       _lightTheme = lightTheme;

  final ThemeData _darkTheme;
  final ThemeData _lightTheme;
  final SplashScreenConfiguration _configuration;
  final BaseServiceItem<dynamic> _themeTask;
  final BaseServiceItem<dynamic> _spinnerTask;

  @override
  State<MaterialRoot> createState() => _MaterialRoot();
}

class _MaterialRoot extends State<MaterialRoot> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        widget._themeTask.blocProvider(),
        widget._spinnerTask.blocProvider(),
      ],
      child: BlocBuilder<ThemeCubitBase, ThemeMode>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, themeMode) => MaterialApp(
          themeMode: themeMode,
          theme: widget._lightTheme,
          darkTheme: widget._darkTheme,
          home: StartupDisplayWidget(
            configuration: widget._configuration,
          ),
        ),
      ),
    );
  }
}
