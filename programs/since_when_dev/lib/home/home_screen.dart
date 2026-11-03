// programs/since_when_dev/lib/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_dev/injection/injection.dart' show getIt;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

import 'status_bar_toggle_cubit.dart' show StatusBarToggleCubit;

/// POC home: a single switch that hides or shows the status bar.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  /// Route of this screen.
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatusBarToggleCubit>(
      create: (_) => StatusBarToggleCubit(getIt<StatusBarVisibilityAbstract>()),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Since When (dev)')),
      body: BlocBuilder<StatusBarToggleCubit, bool>(
        builder: (context, isHidden) => SwitchListTile(
          title: const Text('Hide status bar'),
          subtitle: Text(isHidden ? 'Hidden' : 'Visible'),
          value: isHidden,
          onChanged: (value) =>
              context.read<StatusBarToggleCubit>().setHidden(isHidden: value),
        ),
      ),
    );
  }
}
