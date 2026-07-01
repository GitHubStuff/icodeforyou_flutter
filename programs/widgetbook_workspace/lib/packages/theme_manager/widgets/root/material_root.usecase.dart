// theme_manager/lib/src/widgets/root/material_root.usecase.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:theme_manager/theme_manager.dart'
    show
        MaterialPreference,
        MaterialRoot,
        MaterialTheme,
        MaterialThemeCubit,
        ThemePersistenceAbstract;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

/// Showcases [MaterialRoot] driving a live [MaterialApp].
///
/// Because [MaterialRoot] reads its [MaterialThemeCubit] from the tree, the
/// cubit is provided above it. The hosted home screen embeds a
/// [MaterialPreference] bound to the same cubit, so changing the mode
/// re-themes the entire nested app in real time.
@widgetbook.UseCase(name: 'Default', type: MaterialRoot)
Widget buildMaterialRootUseCase(BuildContext context) {
  return _MaterialRootDemo(
    showDebugBanner: context.knobs.boolean(
      label: 'Show debug banner',
      initialValue: true,
    ),
  );
}

class _MaterialRootDemo extends StatefulWidget {
  const _MaterialRootDemo({required this.showDebugBanner});

  final bool showDebugBanner;

  @override
  State<_MaterialRootDemo> createState() => _MaterialRootDemoState();
}

class _MaterialRootDemoState extends State<_MaterialRootDemo> {
  late final MaterialThemeCubit _cubit = MaterialThemeCubit(
    theme: MaterialTheme(),
    themeModeStorage: _InMemoryThemePersistence(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaterialThemeCubit>.value(
      value: _cubit,
      child: MaterialRoot(
        _DemoHome(cubit: _cubit),
        showDebugBanner: widget.showDebugBanner,
      ),
    );
  }
}

/// Sample home screen that visibly responds to theme changes.
class _DemoHome extends StatelessWidget {
  const _DemoHome({required this.cubit});

  final MaterialThemeCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('theme_manager')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: MaterialPreference(cubit: cubit)),
          const SizedBox(height: 16),
          Text(
            'Sample content',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.palette_outlined),
              title: Text('A themed list tile'),
              subtitle: Text('Colors follow the selected mode'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              TextButton(onPressed: () {}, child: const Text('Text')),
            ],
          ),
        ],
      ),
    );
  }
}

/// In-memory [ThemePersistenceAbstract] so the use case has no dependency
/// on shared preferences or platform channels.
class _InMemoryThemePersistence implements ThemePersistenceAbstract {
  ThemeMode _mode = ThemeMode.dark;

  @override
  FutureOr<ThemeMode> load() => _mode;

  @override
  FutureOr<void> save(ThemeMode mode) => _mode = mode;
}
