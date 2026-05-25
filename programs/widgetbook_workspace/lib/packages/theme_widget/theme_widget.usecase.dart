// widgetbook/lib/theme_widget/theme_widget.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart' show MockPreferences;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart'
    show
        MaterialTheme,
        MaterialThemeCubit,
        MaterialThemeState,
        ThemePersistence;
import 'package:theme_widget/theme_widget.dart' show ThemeWidget;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ThemeWidget)
Widget themeWidgetUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Theme',
  );

  final systemLabel = context.knobs.string(
    label: 'System label',
    initialValue: 'System',
  );

  final darkLabel = context.knobs.string(
    label: 'Dark label',
    initialValue: 'Dark',
  );

  final lightLabel = context.knobs.string(
    label: 'Light label',
    initialValue: 'Light',
  );

  final systemIcon = context.knobs.object.dropdown<IconData>(
    label: 'System icon',
    options: [
      Icons.brightness_auto,
      Icons.settings_brightness,
      Icons.smartphone,
    ],
    initialOption: Icons.brightness_auto,
    labelBuilder: _iconName,
  );

  final darkIcon = context.knobs.object.dropdown<IconData>(
    label: 'Dark icon',
    options: [Icons.dark_mode, Icons.nights_stay, Icons.bedtime],
    initialOption: Icons.dark_mode,
    labelBuilder: _iconName,
  );

  final lightIcon = context.knobs.object.dropdown<IconData>(
    label: 'Light icon',
    options: [Icons.light_mode, Icons.wb_sunny, Icons.wb_incandescent],
    initialOption: Icons.light_mode,
    labelBuilder: _iconName,
  );

  return _ThemeWidgetUseCaseHost(
    title: title,
    systemLabel: systemLabel,
    darkLabel: darkLabel,
    lightLabel: lightLabel,
    systemIcon: systemIcon,
    darkIcon: darkIcon,
    lightIcon: lightIcon,
  );
}

String _iconName(IconData icon) {
  if (icon == Icons.brightness_auto) return 'brightness_auto';
  if (icon == Icons.settings_brightness) return 'settings_brightness';
  if (icon == Icons.smartphone) return 'smartphone';
  if (icon == Icons.dark_mode) return 'dark_mode';
  if (icon == Icons.nights_stay) return 'nights_stay';
  if (icon == Icons.bedtime) return 'bedtime';
  if (icon == Icons.light_mode) return 'light_mode';
  if (icon == Icons.wb_sunny) return 'wb_sunny';
  if (icon == Icons.wb_incandescent) return 'wb_incandescent';
  return icon.toString();
}

/// Composes a [MaterialThemeCubit] from the parts the package exposes —
/// [ThemePersistence.create] for storage (backed by [MockPreferences] in
/// widgetbook so nothing leaks across sessions), [ThemePersistence.load]
/// to restore the saved mode, and [MaterialTheme] to seed the cubit's
/// initial state. The build is async because persistence init is async,
/// so a [FutureBuilder] gates the UI until the cubit is ready.
class _ThemeWidgetUseCaseHost extends StatefulWidget {
  const _ThemeWidgetUseCaseHost({
    required this.title,
    required this.systemLabel,
    required this.darkLabel,
    required this.lightLabel,
    required this.systemIcon,
    required this.darkIcon,
    required this.lightIcon,
  });

  final String title;
  final String systemLabel;
  final String darkLabel;
  final String lightLabel;
  final IconData systemIcon;
  final IconData darkIcon;
  final IconData lightIcon;

  @override
  State<_ThemeWidgetUseCaseHost> createState() =>
      _ThemeWidgetUseCaseHostState();
}

class _ThemeWidgetUseCaseHostState extends State<_ThemeWidgetUseCaseHost> {
  late final Future<MaterialThemeCubit> _cubitFuture = _build();

  MaterialThemeCubit? _cubit;

  Future<MaterialThemeCubit> _build() async {
    final persistence = await ThemePersistence.create(MockPreferences());
    final restoredMode = await persistence.load();
    final cubit = MaterialThemeCubit(
      theme: MaterialTheme(mode: restoredMode),
      themeModeStorage: persistence,
    );
    return cubit;
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MaterialThemeCubit>(
      future: _cubitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to create MaterialThemeCubit:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        _cubit = snapshot.data;
        return _ThemedPreview(
          cubit: snapshot.data!,
          title: widget.title,
          systemLabel: widget.systemLabel,
          darkLabel: widget.darkLabel,
          lightLabel: widget.lightLabel,
          systemIcon: widget.systemIcon,
          darkIcon: widget.darkIcon,
          lightIcon: widget.lightIcon,
        );
      },
    );
  }
}

class _ThemedPreview extends StatelessWidget {
  const _ThemedPreview({
    required this.cubit,
    required this.title,
    required this.systemLabel,
    required this.darkLabel,
    required this.lightLabel,
    required this.systemIcon,
    required this.darkIcon,
    required this.lightIcon,
  });

  final MaterialThemeCubit cubit;
  final String title;
  final String systemLabel;
  final String darkLabel;
  final String lightLabel;
  final IconData systemIcon;
  final IconData darkIcon;
  final IconData lightIcon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialThemeCubit, MaterialThemeState>(
      bloc: cubit,
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: state.light,
          darkTheme: state.dark,
          themeMode: state.mode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('ThemeWidget preview'),
              actions: [
                IconButton(
                  tooltip: 'Reset to System',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: cubit.toSystem,
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ThemeWidget(
                      cubit: cubit,
                      title: title,
                      systemLabel: systemLabel,
                      darkLabel: darkLabel,
                      lightLabel: lightLabel,
                      systemIcon: systemIcon,
                      darkIcon: darkIcon,
                      lightIcon: lightIcon,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Current mode: ${state.mode.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: cubit.toSystem,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('RESET'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Elevated'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Outlined'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Text'),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Filled'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
