// packages/app_navigation/lib/src/chooser/navigation_chooser.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeCubit;

/// Signature for a callback that returns a navigation widget given
/// the current [BuildContext].
typedef NavigationChooserCallback = Widget Function(BuildContext context);

/// {@template navigation_chooser}
/// Executes [chooser] to build and return the active navigation screen.
///
/// Handles restoring theme state and delegates the entire navigation widget
/// selection to the provided callback.
/// {@endtemplate}
class NavigationChooser extends StatelessWidget {
  /// {@macro navigation_chooser}
  const NavigationChooser({
    required this.chooser,
    super.key,
  });

  /// The function invoked to resolve and construct the navigation screen.
  final NavigationChooserCallback chooser;

  @override
  Widget build(BuildContext context) {
    unawaited(context.read<ThemeCubit>().restore());
    return chooser(context);
  }
}
